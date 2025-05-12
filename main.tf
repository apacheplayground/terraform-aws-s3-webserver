
#####################################################################
# LOCALS
#####################################################################

locals {
  bucket_name = var.environment == "" || var.environment == "default" || var.environment == "prod*" ? var.website_parent_domain_name : "${var.environment}.${var.website_parent_domain_name}"

  http_port  = 80
  https_port = 443
}

#####################################################################
# WEBSITE DOMAIN NAME ROUTE53 PUBLIC ZONE 
#####################################################################

data "aws_route53_zone" "website_parent_domain_name" {
  name = var.website_parent_domain_name
}

#####################################################################
# ROOT_DOMAIN BUCKET
#####################################################################

resource "aws_s3_bucket" "root_domain" {
  bucket = local.bucket_name

  tags = {
    Terraform = true
  }
}

resource "aws_s3_bucket_acl" "root_domain" {
  bucket = aws_s3_bucket.root_domain.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "root_domain" {
  bucket = aws_s3_bucket.root_domain.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }

  /*
  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }*/
}

resource "aws_s3_bucket_public_access_block" "root_domain" {
  bucket              = aws_s3_bucket.root_domain.id
  block_public_acls   = false
  block_public_policy = false

  /*
  ignore_public_acls      = false
  restrict_public_buckets = false 
*/
}

resource "aws_s3_bucket_policy" "root_domain" {
  bucket = aws_s3_bucket.root_domain.id
  policy = data.aws_iam_policy_document.root_domain_public_access.json
}

data "aws_iam_policy_document" "root_domain_public_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", ]
    resources = ["${aws_s3_bucket.root_domain.arn}/*", ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    /*  limit website access to certain ip addresses
    Condition {
      IpAddress {
        aws:SourceIp = [
          "[IP1]",
          "[IP2]",
           ......
        ]
      }
    }
    */
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", ]
    resources = ["${aws_s3_bucket.root_domain.arn}", ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject", ]
    resources = ["${aws_s3_bucket.root_domain.arn}/*", ]

    principals {
      type        = "AWS"
      identifiers = var.website_admins
    }
  }
}

#####################################################################
# SUB_DOMAIN BUCKET
#####################################################################

resource "aws_s3_bucket" "sub_domain" {
  bucket = "www.${local.bucket_name}"

  tags = {
    Terraform = true
  }
}

resource "aws_s3_bucket_acl" "sub_domain" {
  bucket = aws_s3_bucket.sub_domain.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "sub_domain" {
  bucket = aws_s3_bucket.sub_domain.id

  redirect_all_requests_to {
    host_name = local.bucket_name
    protocol  = "http"
  }
}

resource "aws_s3_bucket_policy" "sub_domain" {
  bucket = aws_s3_bucket.sub_domain.id
  policy = data.aws_iam_policy_document.sub_domain_deny_put_object.json
}

data "aws_iam_policy_document" "sub_domain_deny_put_object" {
  statement {
    effect    = "Deny"
    actions   = ["s3:PutObject", ]
    resources = ["${aws_s3_bucket.sub_domain.arn}/*", ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

#####################################################################
# ROOT DOMAIN LOG BUCKET
#####################################################################

resource "aws_s3_bucket" "root_log_bucket" {
  bucket = "${local.bucket_name}-logs"

  tags = {
    Terraform = true
  }
}

resource "aws_s3_bucket_acl" "root_log_bucket" {
  bucket = aws_s3_bucket.root_log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "root_domain" {
  bucket        = aws_s3_bucket.root_domain.id
  target_bucket = aws_s3_bucket.root_log_bucket.id
  target_prefix = "log/"
}

#####################################################################
# ROOT DOMAIN CLOUDFRONT DISTRIBUTION
#####################################################################

resource "aws_cloudfront_distribution" "root_domain_distro_non_geo_restriction" {
  count = var.enable_website_geo_restriction == false ? 1 : 0

  enabled             = true
  default_root_object = var.index_document
  aliases             = [local.bucket_name]
  is_ipv6_enabled     = true

  origin {
    domain_name = aws_s3_bucket.root_domain.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.root_domain.bucket

    custom_origin_config {
      http_port              = local.http_port
      https_port             = local.https_port
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.root_domain.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    max_ttl                = 30 * 60
    default_ttl            = 5 * 60

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.ssl_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Name      = "${local.bucket_name}-cf-distro"
    Terraform = true
  }
}

resource "aws_cloudfront_distribution" "root_domain_distro_whitelist_geo_restriction" {
  count = var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "whitelist" ? 1 : 0

  enabled             = true
  default_root_object = var.index_document
  aliases             = [local.bucket_name]
  is_ipv6_enabled     = true

  origin {
    domain_name = aws_s3_bucket.root_domain.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.root_domain.bucket

    custom_origin_config {
      http_port              = local.http_port
      https_port             = local.https_port
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.root_domain.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    max_ttl                = 30 * 60
    default_ttl            = 5 * 60

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.ssl_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.website_whitelisted_countries
    }
  }

  tags = {
    Name      = "${local.bucket_name}-cf-distro"
    Terraform = true
  }
}

resource "aws_cloudfront_distribution" "root_domain_distro_blacklist_geo_restriction" {
  count = var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "blacklist" ? 1 : 0

  enabled             = true
  default_root_object = var.index_document
  aliases             = [local.bucket_name]
  is_ipv6_enabled     = true

  origin {
    domain_name = aws_s3_bucket.root_domain.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.root_domain.bucket

    custom_origin_config {
      http_port              = local.http_port
      https_port             = local.https_port
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.root_domain.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    max_ttl                = 30 * 60
    default_ttl            = 5 * 60

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.ssl_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = var.website_blacklisted_countries
    }
  }

  tags = {
    Name      = "${local.bucket_name}-cf-distro"
    Terraform = true
  }
}

#####################################################################
# SUB DOMAIN CLOUDFRONT DISTRIBUTION
#####################################################################

resource "aws_cloudfront_distribution" "sub_domain_distro_non_geo_restriction" {
  count = var.enable_website_geo_restriction == false ? 1 : 0

  enabled         = true
  aliases         = ["www.${local.bucket_name}"]
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.sub_domain.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.sub_domain.bucket

    custom_origin_config {
      http_port              = local.http_port
      https_port             = local.https_port
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  /*
  s3_origin_config {
    domain_name            = 
    origin_access_identity = 
  }*/

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.sub_domain.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    max_ttl                = 30 * 60
    default_ttl            = 5 * 60

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.ssl_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Name      = "www.${local.bucket_name}-cf-distro"
    Terraform = true
  }
}

resource "aws_cloudfront_distribution" "sub_domain_distro_whitelist_geo_restriction" {
  count = var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "whitelist" ? 1 : 0

  enabled         = true
  aliases         = ["www.${local.bucket_name}"]
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.sub_domain.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.sub_domain.bucket

    custom_origin_config {
      http_port              = local.http_port
      https_port             = local.https_port
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  /*
  s3_origin_config {
    domain_name            = 
    origin_access_identity = 
  }*/

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.sub_domain.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    max_ttl                = 30 * 60
    default_ttl            = 5 * 60

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.ssl_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.website_whitelisted_countries
    }
  }

  tags = {
    Name      = "www.${local.bucket_name}-cf-distro"
    Terraform = true
  }
}

resource "aws_cloudfront_distribution" "sub_domain_distro_blacklist_geo_restriction" {
  count = var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "blacklist" ? 1 : 0

  enabled         = true
  aliases         = ["www.${local.bucket_name}"]
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.sub_domain.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.sub_domain.bucket

    custom_origin_config {
      http_port              = local.http_port
      https_port             = local.https_port
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  /*
  s3_origin_config {
    domain_name            = 
    origin_access_identity = 
  }*/

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.sub_domain.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    max_ttl                = 30 * 60
    default_ttl            = 5 * 60

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.ssl_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = var.website_blacklisted_countries
    }
  }

  tags = {
    Name      = "www.${local.bucket_name}-cf-distro"
    Terraform = true
  }
}

#####################################################################
# WEBSITE DOMAIN NAME A-RECORDS
#####################################################################

locals {
  root_domain_cf_distro_domain_name = (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "whitelist" ? aws_cloudfront_distribution.root_domain_distro_whitelist_geo_restriction[0].domain_name : (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "blacklist" ? aws_cloudfront_distribution.root_domain_distro_blacklist_geo_restriction[0].domain_name : (var.enable_website_geo_restriction == false ? aws_cloudfront_distribution.root_domain_distro_non_geo_restriction[0].domain_name : "")))
  root_domain_cf_distro_hosted_zone = (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "whitelist" ? aws_cloudfront_distribution.root_domain_distro_whitelist_geo_restriction[0].hosted_zone_id : (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "blacklist" ? aws_cloudfront_distribution.root_domain_distro_blacklist_geo_restriction[0].hosted_zone_id : (var.enable_website_geo_restriction == false ? aws_cloudfront_distribution.root_domain_distro_non_geo_restriction[0].hosted_zone_id : "")))

  sub_domain_cf_distro_domain_name = (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "whitelist" ? aws_cloudfront_distribution.sub_domain_distro_whitelist_geo_restriction[0].domain_name : (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "blacklist" ? aws_cloudfront_distribution.sub_domain_distro_blacklist_geo_restriction[0].domain_name : (var.enable_website_geo_restriction == false ? aws_cloudfront_distribution.sub_domain_distro_non_geo_restriction[0].domain_name : "")))
  sub_domain_cf_distro_hosted_zone = (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "whitelist" ? aws_cloudfront_distribution.sub_domain_distro_whitelist_geo_restriction[0].hosted_zone_id : (var.enable_website_geo_restriction == true && var.website_geo_restriction_type == "blacklist" ? aws_cloudfront_distribution.sub_domain_distro_blacklist_geo_restriction[0].hosted_zone_id : (var.enable_website_geo_restriction == false ? aws_cloudfront_distribution.sub_domain_distro_non_geo_restriction[0].hosted_zone_id : "")))
}

data "aws_route53_zone" "root_domain" {
  name = var.website_parent_domain_name
}

resource "aws_route53_record" "root_domain" {
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = local.bucket_name
  type    = "A"

  alias {
    name                   = local.root_domain_cf_distro_domain_name
    zone_id                = local.root_domain_cf_distro_hosted_zone
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "sub_domain" {
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = "www.${local.bucket_name}"
  type    = "A"

  alias {
    name                   = local.sub_domain_cf_distro_domain_name
    zone_id                = local.sub_domain_cf_distro_hosted_zone
    evaluate_target_health = false
  }
}

#####################################################################
# SSL CERT
#####################################################################

module "ssl_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.acm
  }

  domain_name               = local.bucket_name
  subject_alternative_names = ["*.${local.bucket_name}"]

  validation_method       = "DNS"
  wait_for_validation     = false
  create_route53_records  = false
  validation_record_fqdns = module.cnvr.validation_route53_record_fqdns

  tags = {
    Name      = "${local.bucket_name}-ssl-cert"
    Terraform = true
  }
}

module "cnvr" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.route53
  }

  create_certificate          = false
  create_route53_records_only = true

  validation_method                         = "DNS"
  distinct_domain_names                     = module.ssl_cert.distinct_domain_names
  zone_id                                   = data.aws_route53_zone.website_parent_domain_name
  acm_certificate_domain_validation_options = module.ssl_cert.acm_certificate_domain_validation_options

  tags = {
    Terraform = true
  }
}

#####################################################################
# WAF (WEB APPLICATION FIREWALL)
#####################################################################


######################################## APACHEPLAYGROUND™ ########################################