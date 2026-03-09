terraform {
  backend "s3" {
    bucket         = "alambakol-bucket-terraform-state"
    key            = "dev/us-east-1/terraform.tfstate" 
    region         = "us-east-1"
    encrypt        = true
  }
}