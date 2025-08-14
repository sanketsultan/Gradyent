resource "aws_iam_role_policy_attachment" "velero" {
	role       = aws_iam_role.velero.name
	policy_arn = aws_iam_policy.velero.arn
}
resource "aws_iam_role" "eks_node_group_role" {
	name = "eks-node-group-role"
	assume_role_policy = data.aws_iam_policy_document.eks_node_group_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_node_group_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type        = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_AmazonEKSWorkerNodePolicy" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
	role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_AmazonEKS_CNI_Policy" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
	role       = aws_iam_role.eks_node_group_role.name
}


resource "aws_iam_role_policy_attachment" "eks_worker_node_AmazonEC2ContainerRegistryReadOnly" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
	role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_AmazonEBSCSIDriverPolicy" {
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
	role       = aws_iam_role.eks_node_group_role.name
}




resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
	role       = aws_iam_role.eks_node_group_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
	role       = aws_iam_role.eks_node_group_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_caller_identity" "current" {}
# Velero IAM role for backup/restore (IRSA)
resource "aws_iam_role" "velero" {
	name = "velero-irsa-role"
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Principal = {
				Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.cluster_oidc_issuer_url}"
			}
			Action = "sts:AssumeRoleWithWebIdentity"
			Condition = {
				StringEquals = {
					"${module.eks.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:velero:velero"
				}
			}
		}]
	})
}

resource "aws_iam_policy" "velero" {
	name        = "velero-s3-policy"
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
					"arn:aws:s3:::gradyent-velero-backups",
					"arn:aws:s3:::gradyent-velero-backups/*"
				]
			}
		]
	})
}