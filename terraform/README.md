```sh
export KUBECONFIG=$(pwd)/kubeconfig_tf && export AWS_PROFILE=personal
while true ; do kubectl port-forward svc/cluster-argocd-server 8888:80 -n argocd; sleep 1 ; done
```

```sh
argopwd=$( kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d - )
argocd login localhost:8888 --username admin --password=${argopwd}
argocd account update-password --current-password=${argopwd}
```
