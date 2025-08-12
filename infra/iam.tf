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

# Example IRSA role for Kubernetes service account
resource "aws_iam_role" "irsa_role" {
	name = "eks-irsa-role"
	assume_role_policy = data.aws_iam_policy_document.irsa_assume_role_policy.json
}

data "aws_iam_policy_document" "irsa_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRoleWithWebIdentity"]
		principals {
			type        = "Federated"
			identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.cluster_oidc_issuer_url}"]
		}
		condition {
			test     = "StringEquals"
			variable = "${module.eks.cluster_oidc_issuer_url}:sub"
			values   = ["system:serviceaccount:default:example-sa"]
		}
	}
}

data "aws_caller_identity" "current" {}

# Inline policy for the IAM user running Terraform to read EKS AMI SSM parameters
data "aws_iam_policy_document" "ssm_read_eks_ami_params" {
	statement {
		sid     = "AllowReadEKSAMIParams"
		effect  = "Allow"
		actions = [
			"ssm:GetParameter",
			"ssm:GetParameters",
			"ssm:GetParametersByPath",
			"ssm:DescribeParameters"
		]
		resources = [
			"arn:aws:ssm:${var.aws_region}:*:parameter/aws/service/eks/*"
		]
	}

	# Some lookups may require describing images; this action doesn't support resource-level permissions
	statement {
		sid     = "AllowDescribeImages"
		effect  = "Allow"
		actions = [
			"ec2:DescribeImages"
		]
		resources = ["*"]
	}
}

resource "aws_iam_user_policy" "gradyent_ssm_read" {
	name   = "AllowReadEKSAMIParams"
	user   = "gradyent"
	policy = data.aws_iam_policy_document.ssm_read_eks_ami_params.json
}



resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
	role       = aws_iam_role.eks_node_group_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
	role       = aws_iam_role.eks_node_group_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
