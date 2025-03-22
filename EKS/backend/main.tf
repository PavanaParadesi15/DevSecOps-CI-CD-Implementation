## Creating S3 bucket for storing state file in the S3 bucket - Backend
# "s3_bucket" is not the name of the S3 bucket, its the name of the resource "S3"

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = false
  }
}

# Versioning enabled for S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server side encryption enabled for S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


## Creating DynamoDB for State file locking
# "dynamodb-table" is the name of the resource "Dynamo DB" . Its not the table name

resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.dynamodb_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  attribute {
    name = "LockID"
    type = "S"
  }

}
