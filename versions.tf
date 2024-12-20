
# child models and required aws versions
#***************************************
# terraform-aws-modules/acm/aws = >= 4.0   #~> 4.0


#####################################################################
# TERRAFORM
#####################################################################

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = [aws.acm_provider, aws.route53_provider]
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

######################################## APACHEPLAYGROUND™ ########################################
