# Managing Gateway Deployments the GitOps way

This repository uses Weaveworks' Flux: https://github.com/weaveworks/flux. This example repository includes 2 gateway environments which is specified as _dev_ and _test_.

### Re-create secrets for your cluster

Install sealed secrets:
```bash
helm install --namespace kube-system --name sealed-secrets-controller stable/sealed-secrets

```

Install kubeseal:
```bash
GOOS=$(go env GOOS)
GOARCH=$(go env GOARCH)
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/$release/kubeseal-$GOOS-$GOARCH
sudo install -m 755 kubeseal-$GOOS-$GOARCH /usr/local/bin/kubeseal

```

Re-create secrets by running scripts in the scripts folder for each release (dev, test, etc).

### Configure images:
For each HelmRelease yaml files (ie: releases/dev/gateway.yaml):
1) Set the images to use:
   ```helmyaml
   container:
      image: <your repository>/repository/docker-hosted/gateway
      tag: '<your image tag>'
   ```
2) Update the corresponding imageCredentials:
   ```helmyaml
    imageCredentials:
      name: "<your repository>"
      registry: "<your repository>"
      username: "<your repository login>"
   ```
3) Update gateway chart location:
   ```helmyaml
     chart:
       git: git@github.com:<your repo>
   ```

### Install/Configuring Weave Flux

To install Weave Flux:

1) Install flux with helm operation while setting git.url to this repository: https://github.com/weaveworks/flux/tree/master/chart/flux#to-install-flux-with-the-helm-operator 

2) Find the SSH public key with:

```bash
kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2
```

3) Give flux access to sync your cluster state with Git.

On your repository, go to _Setting > Deploy keys_ click on _Add deploy key_, check _Allow write access_, paste the Flux public key and click _Add key_.

By default, flux pulls from the git repo every 5 minutes, be patient!

### Extra WeaveFlux Information

Flux logs:
```bash
kubectl -n flux logs deployment/flux -f
```
Flux's helm-operator logs:
```bash
kubectl -n flux get pods 
kubectl -n flux logs <helm-operator pod name> -f

```

### Fluxctl: 
Fluxctl is a command-line tool to talk to WeaveFlux. 
[Installation instructions](https://github.com/weaveworks/flux/blob/master/site/fluxctl.md)

Run the following commands to view flux deployments:
```bash
fluxctl list-workloads --k8s-fwd-ns flux --all-namespaces
fluxctl list-images --k8s-fwd-ns flux --all-namespaces
```

### Remove WeaveFlux

To remove WeaveFlux:

1) Remove Flux deployment:
```bash
helm del --purge flux
```

2) Delete WeaveFlux related CRDs:
```bash
kubectl delete customresourcedefinitions fluxhelmreleases.helm.integrations.flux.weave.works helmreleases.flux.weave.works
```

### Misc

[Flux Annotations](https://github.com/weaveworks/flux/blob/036221706f3ffdeb215a3a037b97573b7cf17008/site/fluxctl.md#using-annotations)

Troubleshooting:
1) monitor sealed secrets logs to see if any fails to decrypt
2) monitor flux and helm-operator logs 
