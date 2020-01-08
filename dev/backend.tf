provider "vault" {
  address = ""
}

// AWS credentials from Vault for cmf research
data "vault_aws_access_credentials" "sts-creds" {
  backend = "aws"
  role    = "ROLE_AWS"
  type    = "sts"
}
// AWS credentials from Vault for shared infra
data "vault_aws_access_credentials" "sts-shared-dev" {
  backend = "aws"
  role    = "shared-services"
  type    = "sts"
}

//  Setup the core provider information.
provider "aws" {
  region     = var.region
  access_key = data.vault_aws_access_credentials.sts-creds.access_key
  secret_key = data.vault_aws_access_credentials.sts-creds.secret_key
  token      = data.vault_aws_access_credentials.sts-creds.security_token
  version    = "~> 2.0"
}

// Setup the shared infra provider information
provider "aws" {
  alias  = "shared-dev"
  region = var.region

  token      = data.vault_aws_access_credentials.sts-shared-dev.security_token
  access_key = data.vault_aws_access_credentials.sts-shared-dev.access_key
  secret_key = data.vault_aws_access_credentials.sts-shared-dev.secret_key
}

data "vault_generic_secret" "cmf-dev" {
  path = "kv/cmf-dev"
}

terraform {
  required_version = "~> 0.12.0"
  backend "remote" {
    hostname = "terraform.cppib.io"
    organization    = "TEST_ORG"
    workspaces {
      name = "TEST_WORKSPACE"
    }
  }
}