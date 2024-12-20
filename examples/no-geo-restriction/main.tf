
#####################################################################
# WEBSERVER
#####################################################################

module "webserver" {
  source = "apacheplayground/s3-webserver/aws"        #"../../"

  # aws providers argument must be included
  providers = {
    aws                  = aws
    aws.acm_provider     = aws.acm_provider
    aws.route53_provider = aws.route53_provider
  }

  aws_region                 = "us-east-1"
  website_parent_domain_name = "example.com"
}

######################################## APACHEPLAYGROUND™ ########################################
