terraform {
  backend "s3" {
    bucket  = "fodeliapp-terraform-state"
    key     = "dev/terraform.tfstate"
    region  = "ca-central-1"
    profile = "terraform-user"
    encrypt = true
  }
}
