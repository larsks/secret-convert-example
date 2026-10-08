#!/bin/bash

if [[ -z "$CONVERT_SECRET_NAME" ]]; then
  printf "ERROR: secret name was not specified (have you set CONVERT_SECRET_NAME?)\n" >&2
  exit 1
fi

if [[ -z "$NAMESPACE" ]]; then
  printf "ERROR: cannot continue without NAMESPACE\n" >&2
  exit 1
fi

sleepTime=${CONVERT_SECRET_SLEEP_TIME:-10}
insecureValue=${CONVERT_SECRET_INSECURE:-false}

while :; do
  oc get -w -n "$NAMESPACE" secret "$CONVERT_SECRET_NAME" -o name | while read _; do
    if ! secret_json_b64="$(oc -n "$NAMESPACE" get secret "$CONVERT_SECRET_NAME" \
      --ignore-not-found -o jsonpath='{.data.BucketInfo}')"; then
      continue
    fi

    if [[ -z "$secret_json_b64" ]]; then
      printf "WARNING: secret ${CONVERT_SECRET_NAME} was deleted\n" >&2
      oc delete -n "$NAMESPACE" secret "${CONVERT_SECRET_NAME}-converted" --ignore-not-found
      continue
    fi

    secret_json=$(base64 -d <<<"$secret_json_b64")

    if [[ -z "$secret_json" ]]; then
      printf "ERROR: failed to decode secret\n" >&2
      break
    fi

    bucket_name=$(jq -r '.spec.bucketName' <<<"$secret_json")
    endpoint=$(jq -r '.spec.secretS3.endpoint' <<<"$secret_json")
    accessKey=$(jq -r '.spec.secretS3.accessKeyID' <<<"$secret_json")
    secretKey=$(jq -r '.spec.secretS3.accessSecretKey' <<<"$secret_json")

    cat <<EOF | oc apply -n "$NAMESPACE" -f-
apiVersion: v1
kind: Secret
metadata:
  name: "${CONVERT_SECRET_NAME}-converted"
stringData:
    thanos.yaml: |
      type: s3
      config:
        bucket: "$bucket_name"
        endpoint: "$endpoint"
        access_key: "$accessKey"
        secret_key: "$secretKey"
        insecure: $insecureValue
EOF

  done

  printf "WARNING: sleeping for %s seconds before retrying\n" "$sleepTime"
  sleep "$sleepTime"
done
