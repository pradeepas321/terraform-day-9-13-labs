terraform {
  backend "s3" {
    bucket         = "terraform-state-apple-dev"   # Replace with your actual bucket
    key            = "apple/dev/terraform.tfstate"    # Path inside the bucket
    region         = "ap-south-1"
#    dynamodb_table = "terraform-locks"                # DynamoDB table for state locking
    encrypt        = true
  }
}
