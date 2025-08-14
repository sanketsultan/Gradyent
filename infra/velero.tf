resource "aws_s3_bucket" "velero" {
  bucket = "gradyent-velero-backups"
  force_destroy = false
  tags = {
    Name        = "Velero Backup Bucket"
    Environment = "production"
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

resource "aws_iam_role" "velero" {
  name = "velero"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "velero" {
  name        = "velero-policy"
  description = "Velero access to S3 for backups"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.velero.arn,
          "${aws_s3_bucket.velero.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "velero" {
  role       = aws_iam_role.velero.name
  policy_arn = aws_iam_policy.velero.arn
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "arn:aws:eks:${var.aws_region}:${var.aws_account_id}:cluster/${var.cluster_name}"
  }
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  namespace  = "velero"
  create_namespace = true
  set {
    name  = "configuration.provider"
    value = "aws"
  }
  set {
    name  = "configuration.backupStorageLocation.name"
    value = "default"
  }
  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = aws_s3_bucket.velero.bucket
  }
  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = var.aws_region
  }
  set {
    name  = "configuration.backupStorageLocation.config.s3ForcePathStyle"
    value = "true"
  }
  set {
    name  = "credentials.useSecret"
    value = "true"
  }
  set {
    name  = "initContainers[0].name"
    value = "velero-plugin-for-aws"
  }
  set {
    name  = "initContainers[0].image"
    value = "velero/velero-plugin-for-aws:v1.12.1"
  }
  set {
    name  = "serviceAccount.server.annotations[eks.amazonaws.com/role-arn]"
    value = aws_iam_role.velero.arn
  }
}
