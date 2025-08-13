resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
      mapRoles = <<EOF
        - rolearn: ${aws_iam_role.node_group.arn}
          username: system:node:{{EC2PrivateDNSName}}
          groups:
            - system:bootstrappers
            - system:nodes
        - rolearn: arn:aws:iam::${var.aws_account_id}:role/${var.iam_role_name}
          username: admin
          groups:
            - system:masters
        # Local user access (replace with your actual ARN)
        - rolearn: arn:aws:iam::375459824176:user/gradyent
          username: gradyent
          groups:
            - system:masters
        # GitHub Actions uses the same IAM user
        - rolearn: arn:aws:iam::375459824176:user/gradyent
          username: gradyent
          groups:
            - system:masters
      EOF
  }
}
