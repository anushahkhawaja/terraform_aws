terraform {
  backend "remote" {
    organization = "my_company"

    workspaces {
      name = "production"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

module "iam" {
  source  = "app.terraform.io/my_company/iam/aws"
  version = "1.0.0"
}

module "vpc" {
  source  = "app.terraform.io/my_company/vpc/aws"
  version = "1.0.0"

  resource_tags = {
    Environment = "production",
    Project     = "terraform"
  }
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "http rule"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "https rule"
  }]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "all outbound access open"
  }]
   
  webserver_instance_role_name = module.iam.webserver_role_name
}