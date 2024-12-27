
#####################################################################
# GLOBAL VARIABLES
#####################################################################

variable "aws_region" {
  description = "(Required) The AWS region in which the S3 webserver will be created."
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment in which the S3 webserver will be deployed."
  type        = string
  default     = ""
}

variable "website_parent_domain_name" {
  description = "(Required) The parent domain name for the website. This parent domain name should already exist in AWS Route53 as a prerequisite."
  type        = string
  default     = ""
}

#####################################################################
# HTML DOCS VARIABLES
#####################################################################

variable "index_document" {
  description = "The full path to the index.html document for the website."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The full path to the error.html document for the website."
  type        = string
  default     = "error.html"
}

#####################################################################
# WEBSITE GEO RESTRICTION VARIABLES
#####################################################################

variable "enable_website_geo_restriction" {
  description = "Whether or not to enable geographical restriction for website access."
  type        = bool
  default     = false
}

variable "website_geo_restriction_type" {
  description = "The type of geographical restriction to implement for website access. Only valid if 'enable_website_geo_restriction' is true."
  type        = string
  default     = ""
}

variable "website_whitelisted_countries" {
  description = "The list of countries (by Alpha-2 code) that should be whitelisted for accessing the website. Only valid if 'enable_website_geo_restriction' is true and 'website_geo_restriction_type' is whitelist. The full list of country codes can be found at https://www.iso.org/obp/ui/#search."
  type        = list(string)
  default     = []
}

variable "website_blacklisted_countries" {
  description = "The list of countries (by Alpha-2 code) that should be blacklisted from accessing the website. Only valid if 'enable_website_geo_restriction' is true and 'website_geo_restriction_type' is blacklist. The full list of country codes can be found at https://www.iso.org/obp/ui/#search."
  type        = list(string)
  default     = []
}

######################################## APACHEPLAYGROUND™ ########################################