terraform {
  backend "s3" {
    bucket         = "medsarv-terraform-state-021541384758"
    key            = "medsarv/terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "medsarv-terraform-locks"
    encrypt        = true
  }
}
