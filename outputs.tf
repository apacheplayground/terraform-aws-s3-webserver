
output "website_url" {
  description = "The URL of the website."
  value       = local.bucket_name
}

output "webserver_bucket_id" {
  description = "The ID of the webserver S3 bucket."
  value       = aws_s3_bucket.root_domain.id
}

######################################## APACHEPLAYGROUND™ ########################################