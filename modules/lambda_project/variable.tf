variable "resource_name" {
  description = "Prefix for all resources"
  default     = "rds-manager"
  type        = string  
}

# Where the code LIVES (Virginia)
variable "region" {
  description = "The AWS region to deploy the Lambda into"
  default     = "us-east-1"
  type        = string
}

# Where the code WORKS (Patrol Route)
variable "target_regions" {
  description = "A comma-separated list of regions the Lambda should manage"
  type        = string
  default     = "us-east-1" 
}

# The clock the code FOLLOWS (New York Time)
variable "timezone" {
  description = "The timezone for the schedule"
  type        = string
  default     = "America/New_York"
}