# terraform {
#   backend "remote" {  
#     hostname="app.terraform.io"  
#     organization = "prodxcloud" 
#     workspaces {
#       prefix = "prodxcloud" 
#     }
#   }
# }

terraform {
  backend "s3" {
    bucket         = "iteam-project"
    region         = "eu-west-3"
    key            = "state/terraform.tfstate"
    encrypt        = true
  }
}


