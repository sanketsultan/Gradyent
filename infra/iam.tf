
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
