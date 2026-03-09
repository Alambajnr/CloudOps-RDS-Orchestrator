terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"
    key            = "dev.lamba_project/ap-south-1/tfstate"
    region         = "us-east-1"
    use_lockfile   = true
  }
}