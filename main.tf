terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "gcs" {}
}
data "terraform_remote_state" "gke_cluster" {
  backend = "gcs"
  config {
    bucket  = "${var.gke_cluster_remote_state["bucket"]}"
    prefix  = "${var.gke_cluster_remote_state["prefix"]}"
  }
}
data "google_client_config" "current" {}

provider "google" {
  region      = "${var.provider["region"]}"
  project     = "${var.provider["project"]}"
}

provider "kubernetes" {
  load_config_file = false

  host                   = "${data.terraform_remote_state.gke_cluster.endpoint}"
  token                  = "${data.google_client_config.current.access_token}"
  cluster_ca_certificate = "${base64decode(data.terraform_remote_state.gke_cluster.cluster_ca_certificate)}"
}

provider "helm" {
  tiller_image = "gcr.io/kubernetes-helm/tiller:${lookup(var.helm, "version", "v2.11.0")}"

  install_tiller = true
  service_account = "${data.terraform_remote_state.gke_cluster.tiller_service_account}"
  namespace = "kube-system"

  kubernetes {
    host                   = "${data.terraform_remote_state.gke_cluster.endpoint}"
    token                  = "${data.google_client_config.current.access_token}"
    cluster_ca_certificate = "${base64decode(data.terraform_remote_state.gke_cluster.cluster_ca_certificate)}"
  }
}

resource "helm_repository" "certmanager_cluster_issuer" {
    name = "certmanager-cluster-issuer"
    url  = "https://raw.githubusercontent.com/Acaisoft/certmanager-cluster-issuer/v0.1.1/"
}
resource "helm_repository" "cert_manager" {
    name = "jetstack"
    url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert_manager" {
    name      = "cert-manager"
    chart     = "${lookup(var.cert_manager, "chart", "jetstack/cert-manager")}"
    namespace = "${lookup(var.cert_manager, "namespace", "cert-manager")}"
    version   = "${lookup(var.cert_manager, "version", "v0.12.0")}"
    values = [
        "${file(lookup(var.cert_manager, "values", "cert-manager-values.yaml"))}"
    ]
}

resource "helm_release" "cluster_issuer" {
    name         = "cluster-issuer"
    repository   = "${helm_repository.certmanager_cluster_issuer.metadata.0.name}"
    chart        = "cm-cluster-issuer"
    namespace    = "${lookup(var.cluster_issuer, "namespace", "cert-manager")}"
    version      = "${lookup(var.cluster_issuer, "version", "0.1.1")}"
    values = [
        "${file(lookup(var.cluster_issuer, "values", "issuer-values.yaml"))}"
    ]
    depends_on = ["helm_release.cert_manager"]

}
resource "helm_release" "nginx_ingress" {
    name         = "nginx-ingress"
    chart        = "stable/nginx-ingress"
    namespace    = "${lookup(var.nginx_ingress, "namespace", "ingress-controller")}"
    force_update = true
    version      = "${lookup(var.nginx_ingress, "version", "1.3.1")}"
    values = [
        "${file(lookup(var.nginx_ingress, "values", "nginx-values.yaml"))}"
    ]
    depends_on = ["helm_release.cert_manager"]
}
