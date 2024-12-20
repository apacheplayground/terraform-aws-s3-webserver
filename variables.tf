
#####################################################################
# GLOBAL VARIABLES
#####################################################################

variable "aws_region" {
  description = "The AWS region in which the AWS S3 webserver will be created."
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment in which the AWS S3 webserver will be deployed."
  type        = string
  default     = ""
}

variable "website_parent_domain_name" {
  description = "The parent domain name for the website. This parent domain name should already exist in AWS Route53 as a prerequisite."
  type        = string
  default     = ""
}

#####################################################################
# HTML DOCS VARIABLES
#####################################################################

variable "index_document" {
  description = "The full path to the index html document for the website."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The full path to the error html document for the website."
  type        = string
  default     = "error.html"
}

#####################################################################
# WEBSITE GEO RESTRICTION VARIABLES
#####################################################################

variable "enable_website_geo_restriction" {
  description = "Whether or not to enable geo restriction for website access."
  type        = bool
  default     = false
}

variable "website_geo_restriction_type" {
  description = "The type of geo restriction to implement for website access. Only valid if 'enable_website_geo_restriction' is true."
  type        = string
  default     = ""
}

variable "website_whitelisted_countries" {
  description = "The list of countries (by Alpha-2 code) that should be whitelisted for access to the website access. Only valid if 'enable_website_geo_restriction' is true and 'website_geo_restriction_type' is whitelist. The full list of country codes can be found [here](https://www.iso.org/obp/ui/#search)."
  type        = list(string)
  default     = []
}

variable "website_blacklisted_countries" {
  description = "The list of countries (by Alpha-2 code) that should be blacklisted from access to the website access. Only valid if 'enable_website_geo_restriction' is true and 'website_geo_restriction_type' is blacklist. The full list of country codes can be found [here](https://www.iso.org/obp/ui/#search)."
  type        = list(string)
  default     = []
}

#####################################################################
# WEBPAGES VARIABLES
#####################################################################

variable "webpages_upload_source" {
  description = "The source from which webpages will be uploaded to the webserver. Valid values are 'root-module' and 'remote'. When set to 'root-module', webpages will be uploaded by placing them in a 'webpages' directory in the root module. When set to 'remote', webpages will have to be uploaded from a remote source e.g a GitHub repository (via a GitHub actions workflow which will have to be setup separately by the module user)."
  type        = string
  default     = "root-module"
}

######################################## APACHEPLAYGROUND™ ########################################