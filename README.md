# AWS S3 Webserver Terraform module
===================================

Terraform module to create a webserver on an AWS S3 bucket.

The module comes with the following features:
  - Geographical restriction through whitelisting or blacklisting of select countries


## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# aws providers block for acm_provider must be included
provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

# aws providers block for route53_provider must be included
provider "aws" {
  alias  = "route53_provider"
  region = "us-east-1"
}


module "webserver" {
  source  = "apacheplayground/s3-webserver/aws"

  # aws providers argument must be included
  providers = {
    aws                  = aws
    aws.acm_provider     = aws.acm_provider
    aws.route53_provider = aws.route53_provider
  }

  aws_region                 = "us-east-1"
  website_parent_domain_name = "example.com"
}
```

## Examples

See [examples](https://github.com/apacheplayground/terraform-aws-s3-webserver/tree/main/examples) for example usage scenarios.


## Reporting bugs and contributing

- Want to report a bug or request a feature? Please open [an issue](https://github.com/apacheplayground/terraform-aws-s3-webserver/issues/new).


## Licensing

This module is licensed under the Apache-2.0 license. See [LICENSE](./LICENSE) for reference.

The module also uses other Terraform modules. See [ATTRIBUTIONS.md](./ATTRIBUTIONS.md) for a list.