terraform {
  backend "s3" {
    bucket = "mikes_terraform_state"
    key    = "mikes_infra.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}
