# s3 backend with dynamodb and locking enabled

terraform {
  backend "s3" {
    bucket         = "terraform-state-eks-productionenv"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
  }
}
