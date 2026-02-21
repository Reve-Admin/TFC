terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    pinecone = {
      source  = "pinecone-io/pinecone"
      version = "~> 0.7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "pinecone" {
  api_key = var.pinecone_api_key
}