variable "datadog_api_key" {
  description = "Datadog API key for agent deployment"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for Datadog agent"
  type        = string
}
