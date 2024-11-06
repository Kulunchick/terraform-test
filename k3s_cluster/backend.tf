terraform {
  backend "s3" {
    bucket         = "terraform-state-the-acing"
    key            = "global/k3s_cluster/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-locks-the-acing"
    encrypt        = true
  }
}