resource "aws_s3_bucket" "terraform_state" {
  count  = var.create_state_resources ? 1 : 0
  bucket = "gradyent-terraform-state"
  force_destroy = true
  lifecycle {
  prevent_destroy = true
  }
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  count  = var.create_state_resources ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  count  = var.create_state_resources ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  count        = var.create_state_resources ? 1 : 0
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  lifecycle {
  prevent_destroy = true
  }
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "Terraform Lock Table"
    Environment = "dev"
  }
}
