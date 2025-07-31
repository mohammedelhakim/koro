terraform {
  backend "s3" {
    bucket         = "koro-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "koro-terraform-lock-table"
    encrypt        = true
  }
}
