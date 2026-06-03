terraform {
  backend "s3" {
    bucket         = "terraform-state-apple-dev"   # Replace with your bucket name
    key            = "apple/dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true
  }
}
