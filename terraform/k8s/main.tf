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
}

# export KUBE_CONFIG_PATH=/path/to/.kube/config

# resource "helm_release" "argocd" {
#   name       = "cluster"

#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   namespace  = "argocd"

#   # values = [
#   #   file("${path.module}/argo-values-cd.yaml")
#   # ]

#   depends_on = [
#     kubernetes_namespace.argocd
#   ]

#   set {
#     name  = "installCRDs"
#     value = "false"
#   }
# }


## Bootstrap
resource "helm_release" "argocd" {
  name       = "cluster"
  chart      = "./charts/argocd"
  namespace  = "argocd"
  create_namespace = true
  depends_on = [
    kubernetes_namespace.argocd
  ]
}