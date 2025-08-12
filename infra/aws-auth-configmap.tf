resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<EOF
- rolearn: arn:aws:iam::${var.aws_account_id}:role/${var.iam_role_name}
  username: admin
  groups:
    - system:masters
- rolearn: arn:aws:iam::${var.aws_account_id}:role/${var.node_group_role_name}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }
}
