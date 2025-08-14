resource "aws_s3_bucket" "velero" {
  bucket = "gradyent-velero-backups"
  force_destroy = false
  lifecycle {
  prevent_destroy = true
  }
  tags = {
    Name        = "Velero Backup Bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "velero" {
  bucket = aws_s3_bucket.velero.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "velero" {
  bucket = aws_s3_bucket.velero.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


// create namespace
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}

