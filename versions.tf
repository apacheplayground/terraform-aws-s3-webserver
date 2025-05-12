
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
      version               = ">= 4.40"
      configuration_aliases = [aws.acm, aws.route53]
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

######################################## APACHEPLAYGROUND™ ########################################