provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:eu-west-1:375459824176:cluster/gradyent-eks"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:eu-west-1:375459824176:cluster/gradyent-eks"
  }
}

resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = kubernetes_namespace.observability.metadata[0].name
  version    = "3.54.0"

  set {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }
  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}
