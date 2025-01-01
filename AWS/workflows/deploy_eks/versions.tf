#https://developer.hashicorp.com/terraform/language/backend/s3
terraform {
    backend "s3" {
        bucket = "gerard-terraformstate"
        key    = "eks/gerard-terraformstate.tfstate"
        region = "us-west-1"
        /*assume_role = {
            role_arn = "arn:aws:iam::ACCOUNTID:role/TerraformRole"
        }*/
    }
}
