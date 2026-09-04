terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Values intentionally left blank here — backend blocks can't reference
  # variables. Run `terraform init -backend-config=backend.hcl` with a
  # backend.hcl (gitignored, see backend.hcl.example) populated from
  # `terraform output` in ../../bootstrap.
  backend "s3" {}
}
