
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

######################################## APACHEPLAYGROUND™ ########################################
