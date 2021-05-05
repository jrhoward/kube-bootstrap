terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-argo"
}


resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      name = "argocd"
    }

    # labels = {
    #   mylabel = "label-value"
    # }

    name = "argocd"
  }
  timeouts {

    delete = "30m"
  }
}

# export KUBE_CONFIG_PATH=/path/to/.kube/config

resource "helm_release" "argocd" {
  name       = "cluster"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  values = [
    file("${path.module}/charts/argo-overrides/argo-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]

  set {
    name  = "installCRDs"
    value = "false"
  }
}


## Bootstrap
resource "helm_release" "argocd_app_of_apps" {
  name       = "bootstrap"
  chart      = "./charts/app-of-apps"
  namespace  = "argocd"
  #dependency_update = true
  # values = [
  #   file("${path.module}/charts/argocd/values.yaml")
  # ]
  depends_on = [
    helm_release.argocd
  ]
}