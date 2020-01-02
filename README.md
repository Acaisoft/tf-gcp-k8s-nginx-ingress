# Nginx Ingress Controller Module

Nginx Ingress Controller with Cert Manager and Let's Encrypt cluster issuer. 

# Initial Deploy
Before deploy this chart first time you need to manualy deploy CRDs for proper cert-manager version

```
kubectl apply --validate=false\
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
```

# Update from version cert-manager < 0.12
If you updating from previous cert-manager version < 0.11:
  1. destroy module
  2. delete namespaces
  3. delete crds 

```
kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v0.10.1/cert-manager.yaml
```  
  
  4. install new crds for proper cert-manager version.
  5. deploy this module
  6. update annotations in all ingresses from 
  `certmanager.k8s.io/cluster-issuer:`
  to
  `cert-manager.io/cluster-issuer:`