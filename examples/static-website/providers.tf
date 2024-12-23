
#####################################################################
# PROVIDERS
#####################################################################

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

provider "aws" {
  alias  = "route53_provider"
  region = "us-east-1"
}

######################################## APACHEPLAYGROUND™ ########################################
