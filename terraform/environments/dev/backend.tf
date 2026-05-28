
terraform {
  backend "s3" {
    bucket  = "demo-newbucket-terraform1"
    key     = "eks-platform/dev/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
    # profile = "terraform-sessions"
  }
}
