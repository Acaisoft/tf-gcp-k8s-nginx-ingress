# Parameters authorized:
# version (default: v2.11.0)
variable "helm" {
  type        = "map"
  description = "Helm provider parameters"
  default     = {}
}

# Parameters authorized:
# project (mandatory)
# region (mandatory)
variable "provider" {
  type        = "map"
  description = "Google provider parameters"
}

# Parameters authorized:
# bucket (mandatory)
# prefix (mandatory)
variable "gke_cluster_remote_state" {
  type        = "map"
  description = "GKE cluster remote state parameters"
}

# Parameters authorized:
# namespace (default: ingress-controller)
# version (default: v0.12.0)
# chart (default: jetstack/cluster-issuer )
# values (default: cert-manager-values.yaml)
variable "cert_manager" {
  type        = "map"
  description = "Cert manager configuration"
  default     = {}
}

# Parameters authorized:
# namespace (default: ingress-controller)
# version (default: 0.1.0)
# values (default: issuer-values.yaml)
variable "cluster_issuer" {
  type        = "map"
  description = "Letsencrypt cluster issuer configuration"
  default     = {}
}

# Parameters authorized:
# namespace (default: ingress-controller)
# version (default: 1.3.1)
# values (default: nginx-values.yaml)
variable "nginx_ingress" {
  type        = "map"
  description = "Nginx ingress controller configuration"
  default     = {}
}
