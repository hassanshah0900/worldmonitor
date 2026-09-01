terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Deliberately no backend block here: this config creates the S3 bucket +
  # DynamoDB table that everything else uses as its remote backend, so it
  # can't depend on that backend existing yet. State for `bootstrap/` stays
  # local — run it once, keep terraform.tfstate somewhere safe (or import it
  # into the bucket manually afterwards), and rarely touch it again.
}
