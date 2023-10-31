terraform {
  backend "s3" {
    bucket = "${name}_terraform_state"
    key    = "${name}_infra.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}
