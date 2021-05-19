provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    cluster_ca_certificate = var.k8s_cert
    token                  = var.k8s_token
  }
}
# Deploy ArgoCD helm chart to cluster
resource "helm_release" "argocd" {
  name = "cluster"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/manifests/charts/argo-overrides/argo-values.yaml")
  ]
  set {
    name  = "installCRDs"
    value = "false"
  }
}


## Bootstrap the applicationsß
resource "helm_release" "argocd_app_of_apps" {
  name      = "bootstrap"
  chart     = "${path.module}/manifests/charts/app-of-apps"
  namespace = "argocd"
  depends_on = [
    helm_release.argocd
  ]
}
