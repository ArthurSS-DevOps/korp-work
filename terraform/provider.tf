provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "projeto-korp"
      Environment = "challenge"
      ManagedBy   = "terraform"
    }
  }
}