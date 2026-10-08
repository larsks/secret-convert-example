# Converting a secret into a different format

This projects uses a SecretStore and ExternalSecret to convert a COSI bucket secret into a format suitable for use with ACM MultiClusterObservability.

To see this in action:

1. Edit `kustomization.yaml` to target a namespace in which you are able to create resources.

2. Deploy the code:

    ```sh
    oc apply -k .
    ```

3. Create the example secret:

    ```sh
    oc apply -f example-secret.yaml
    ```

You should immediately see a new secret `bucketclaim-example-bucket-converted`:

```sh
$ oc extract secret/bucketclaim-example-bucket-converted --to=-
# thanos.yaml

type: s3
config:
  bucket: fb-bucketbd9d1050-bda8-437f-996b-dde341f5fb72
  endpoint: s3.infra.oac.ocp.massopen.cloud
  access_key: ACCESSKEY
  secret_key: SECRETKEY
  insecure: false
```
