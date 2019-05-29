# Configuring Secrets

The following commands creates a secret encrypted by Kubeseal for the specified information, where '<namespace>' indicates which environment your secrets are created in:

Secret encrypted by Kubeseal for image credentials:
```bash
./makeImageCreds.sh -namespace=<namespace> -dest=../releases/<namespace>/image-creds.yaml -password=<password>
```

This command creates a Secret encrypted by Kubeseal for license:
```bash
./makeLicense.sh -namespace=<namespace> -dest=../releases/<namespace>/gateway-license.yaml -license=<license.xml file>
```

This command creates a Secret encrypted by Kubeseal for environment properties:
```bash
kubectl create secret generic env --dry-run  -n <namespace>  -o yaml --from-file=env.yaml  | kubeseal --format yaml > "../releases/<namespace>/env.yaml"
```