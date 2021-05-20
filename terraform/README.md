export KUBECONFIG=/Users/jahoward/code/clients/internal/experiments/github/kube-bootstrap/terraform/aws/kubeconfig_tf && export AWS_PROFILE=personal
while true ; do kubectl port-forward svc/cluster-argocd-server 8888:80 -n argocd; sleep 1 ; done

while true ; do kubectl port-forward svc/cluster-argocd-server 8888:80 -n argocd; sleep 1 ; done

export KUBECONFIG=/Users/jahoward/code/clients/internal/experiments/github/kube-bootstrap-recover/terraform/aws/kubeconfig_k8s-b470a3a5 && export AWS_PROFILE=personal
argopwd=$( kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d - )
argocd login localhost:8888 --username admin --password=${argopwd}
argocd account update-password --current-password=${argopwd}