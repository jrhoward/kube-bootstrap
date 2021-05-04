apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    server: {{ .Values.appofapps.spec.destination.server }}
    namespace: argocd
  project: default
  source:
    path: terraform/k8s/charts/argo-applications
    repoURL: {{ .Values.appofapps.spec.source.repoURL }}
    targetRevision: {{ .Values.appofapps.spec.source.targetRevision }}
    helm:
      releaseName: app-of-apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
