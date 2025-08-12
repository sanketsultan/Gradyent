resource "aws_iam_role" "gradyent_admin" {
  name = "gradyent"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::375459824176:user/gradyent"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
