module "lambda_project" {
  source         = "../../../../modules/lambda_project"
  
  region         = "us-east-1"
  timezone       = "America/New_York"
  resource_name  = "rds-orchestrator"
  target_regions = "us-east-1,ap-south-1"
}