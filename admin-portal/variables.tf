variable "project_name" {
  default = "admin-portal"
}

# Only "dev" exists for now; add test/prd entries here later the same way
# emr/variables.tf does, once those environments are actually needed.
variable "environments" {
  default = {
    dev = {
      instance_type = "t3.micro"
      domain        = "admin-dev.medsarv.com"
    }
  }
}
