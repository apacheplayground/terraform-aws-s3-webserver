
# used child models and their required aws versions
#**************************************************
# terraform-aws-modules/acm/aws = >= 4.40

#####################################################################
# TERRAFORM
#####################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40"
    }
  }
}

#####################################################################
# PROVIDERS
#####################################################################

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}

provider "aws" {
  alias  = "route53"
  region = "us-east-1"
}

#####################################################################
# WEBSERVER
#####################################################################

module "webserver" {
  source = "../../"

  # all 3 aws providers must be included
  providers = {
    aws         = aws
    aws.acm     = aws.acm
    aws.route53 = aws.route53
  }

  aws_region                 = "us-east-1"
  website_parent_domain_name = "example.com"
}

######################################## APACHEPLAYGROUND™ ########################################