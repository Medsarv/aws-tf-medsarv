variable "project_name" {
  default = "medrecord-pro"
}

variable "environments" {
  default = {
    dev = {
      instance_type    = "t3.small"
      db_instance_type = "db.t3.micro"
      domain           = "dev.medsarv.com"
    }
    test = {
      instance_type    = "t3.small"
      db_instance_type = "db.t3.micro"
      domain           = "test.medsarv.com"
    }
    prd = {
      instance_type    = "t3.medium"
      db_instance_type = "db.t3.small"
      domain           = "medsarv.com"
    }
  }
}
