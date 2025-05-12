# AWS S3 Webserver Terraform module

Terraform module to create a webserver on an AWS S3 bucket.

## Usage

### Basic usage
```hcl
# default aws provider
provider "aws" {
  region = "us-east-1"
}

# aws.acm provider block must be included
provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}

# aws.route53 provider block must be included
provider "aws" {
  alias  = "route53"
  region = "us-east-1"
}


module "webserver" {
  source  = "apacheplayground/s3-webserver/aws"

  # all 3 aws providers must be included
  providers = {
    aws         = aws
    aws.acm     = aws.acm
    aws.route53 = aws.route53
  }

  aws_region                 = "us-east-1"
  website_parent_domain_name = "website-domain-name.com"
}
```

### Uploading webpages to webserver (from within root module)

```hcl
resource "aws_s3_object" "webpages" {
  for_each = fileset("${path.root}/webpages-directory/", "**")

  bucket = module.webserver.bucket_id
  key    = each.value
  source = "${path.root}/webpages-directory/${each.value}"
  etag   = filemd5("${path.root}/webpages-directory/${each.value}")
}
```

### Uploading webpages to webserver (from outside root module)

```hcl
data "aws_s3_bucket" "webserver" {
  bucket = "webserver_bucket_name"
}

resource "aws_s3_object" "webpages" {
  for_each = fileset("${path.root}/webpages-directory/", "**")

  bucket = data.aws_s3_bucket.webserver.id
  key    = each.value
  source = "${path.root}/webpages-directory/${each.value}"
  etag   = filemd5("${path.root}/webpages-directory/${each.value}")
}
```

### Enabling geo restriction
```hcl
module "webserver" {
  source  = "apacheplayground/s3-webserver/aws"

  # all 3 aws providers must be included
  providers = {
    aws         = aws
    aws.acm     = aws.acm
    aws.route53 = aws.route53
  }

  aws_region                 = "us-east-1"
  website_parent_domain_name = "website-domain-name.com"

  enable_website_geo_restriction = true
  website_geo_restriction_type   = "whitelist"
  website_whitelisted_countries  = ["US", "CA"]
}
```

## Examples

See [examples](https://github.com/apacheplayground/terraform-aws-s3-webserver/tree/main/examples) for example usage scenarios.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.40 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cnvr"></a> [cnvr](#module\_cnvr) | terraform-aws-modules/acm/aws | ~> 4.0 |
| <a name="module_ssl_cert"></a> [ssl\_cert](#module\_ssl\_cert) | terraform-aws-modules/acm/aws | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.root_domain_distro_blacklist_geo_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.root_domain_distro_non_geo_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.root_domain_distro_whitelist_geo_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.sub_domain_distro_blacklist_geo_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.sub_domain_distro_non_geo_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.sub_domain_distro_whitelist_geo_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_route53_record.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.root_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.root_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_logging.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_website_configuration.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_bucket_website_configuration.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_iam_policy_document.root_domain_public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sub_domain_deny_put_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.website_parent_domain_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | (Required) The AWS region in which the S3 webserver will be created. | `string` | `""` | no |
| <a name="input_enable_website_geo_restriction"></a> [enable\_website\_geo\_restriction](#input\_enable\_website\_geo\_restriction) | Whether or not to enable geographical restriction for website access. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment in which the S3 webserver will be deployed. | `string` | `""` | no |
| <a name="input_error_document"></a> [error\_document](#input\_error\_document) | The S3 object key of the error document for the website. This document should be placed in the root directory of the S3 bucket. | `string` | `"error.html"` | no |
| <a name="input_index_document"></a> [index\_document](#input\_index\_document) | The S3 object key of the index document for the website. This document should be placed in the root directory of the S3 bucket. | `string` | `"index.html"` | no |
| <a name="input_website_admins"></a> [website\_admins](#input\_website\_admins) | The list of IAM entities (users, roles) that are allowed to upload and/or remove webpages from the webserver. Defaults to all (*) IAM entities on the AWS account. | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_website_blacklisted_countries"></a> [website\_blacklisted\_countries](#input\_website\_blacklisted\_countries) | The list of countries (by Alpha-2 code) that should be blacklisted from accessing the website. Only valid if 'enable\_website\_geo\_restriction' is true and 'website\_geo\_restriction\_type' is blacklist. The full list of country codes can be found at https://www.iso.org/obp/ui/#search. | `list(string)` | `[]` | no |
| <a name="input_website_geo_restriction_type"></a> [website\_geo\_restriction\_type](#input\_website\_geo\_restriction\_type) | The type of geographical restriction to implement for website access. Only valid if 'enable\_website\_geo\_restriction' is true. | `string` | `""` | no |
| <a name="input_website_parent_domain_name"></a> [website\_parent\_domain\_name](#input\_website\_parent\_domain\_name) | (Required) The parent domain name for the website. This parent domain name should already exist in AWS Route53 as a prerequisite. | `string` | `""` | no |
| <a name="input_website_whitelisted_countries"></a> [website\_whitelisted\_countries](#input\_website\_whitelisted\_countries) | The list of countries (by Alpha-2 code) that should be whitelisted for accessing the website. Only valid if 'enable\_website\_geo\_restriction' is true and 'website\_geo\_restriction\_type' is whitelist. The full list of country codes can be found at https://www.iso.org/obp/ui/#search. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_webserver_bucket_id"></a> [webserver\_bucket\_id](#output\_webserver\_bucket\_id) | The ID of the webserver S3 bucket. |
| <a name="output_website_url"></a> [website\_url](#output\_website\_url) | The URL of the website. |
<!-- END_TF_DOCS -->