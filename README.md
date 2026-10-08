# Converting a secret into a different format

This projects uses a script to convert a COSI bucket secret into a format suitable for use with ACM MultiClusterObservability. We use the `image-registry.openshift-image-registry.svc:5000/openshift/tools:latest` image, which is available in any OpenShift cluster and includes both the `oc` and `jq` commands. Our script watches for changes to a specific secret, and on any update it generates a new secret (with `-converted` appended to the original name) in the new format.

To see this in action:

1. Deploy the code:

    ```
    oc apply -k .
    ```

2. In one terminal, watch the logs on the convert-secret pod:

    ```
    oc logs -f deployment/convert-secret
    ```

3. In another terminal, apply `example-secret-yaml`:

    ```
    oc apply -f example-secret.yaml
    ```

You should see output like this in the logs:

```
Error from server (NotFound): secrets "bucketclaim-example-bucket" not found
sleeping for 10 seconds before retrying
Error from server (NotFound): secrets "bucketclaim-example-bucket" not found
sleeping for 10 seconds before retrying
secret/bucketclaim-example-bucket-converted configured
```

Make any changes to the source secret and you should see the script wake up and re-apply the transformation.
