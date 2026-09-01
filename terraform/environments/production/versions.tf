terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Values intentionally left blank here — backend blocks can't reference
  # variables. Run `terraform init -backend-config=backend.hcl` with a
  # backend.hcl (gitignored, see backend.hcl.example) populated from
  # `terraform output` in ../../bootstrap.
  backend "s3" {}
}
