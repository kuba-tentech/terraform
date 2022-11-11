terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "kubatentech-handson"
    key     = "handson_statefile"
    profile = "default"
  }
}
