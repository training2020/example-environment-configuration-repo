#!/bin/sh
echo "Usage: ./makeLicense.sh -namespace=default -dest=destination.yaml -license=license.xml"

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)

    case "$KEY" in
            -namespace)             namespace=${VALUE} ;;
            -license)               license=${VALUE} ;;
            -dest)                  destination=${VALUE} ;;
            *)
    esac
done

OUT="$(mktemp)"
echo "gateway:" >> "$OUT"
echo "  license:" >> "$OUT"
echo "    accept: \"true\"" >> "$OUT"
echo "    value: |+" >> "$OUT"
awk  '{ print "      " $0 }'  "$license" >> "$OUT"
kubectl create secret generic gateway-license --dry-run  -n "$namespace"  -o yaml --from-file=license.yaml="$OUT"  | kubeseal --format yaml > "$destination"
# | kubeseal --format yaml
if [ $? -eq 0 ]; then
    echo "Secret created in $destination"
else
    echo Failed to create secret
fi

rm "$OUT"