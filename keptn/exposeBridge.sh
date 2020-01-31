#!/bin/bash
echo "Update Bridge to Early Access Version"
kubectl -n keptn set image deployment/bridge bridge=keptn/bridge2:0.6.1.EAP.20200131.1010 --record
kubectl -n keptn-datastore set image deployment/mongodb-datastore mongodb-datastore=keptn/mongodb-datastore:0.6.1.EAP.20200131.1010 --record

echo ""
echo "============================================================="
echo "About to create a VirtualService to the Keptn Bridge service"
echo "============================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

DOMAIN=$(kubectl get cm keptn-domain -n keptn -ojsonpath={.data.app_domain})

rm -f ./manifests/gen/bridge.yaml
mkdir -p ./manifests/gen
cat ./manifests/bridge.yaml | \
  sed 's~DOMAIN_PLACEHOLDER~'"$DOMAIN"'~' > ./manifests/gen/bridge.yaml

kubectl apply -f ./manifests/gen/bridge.yaml

echo "Bridge URL: https://bridge.keptn.$DOMAIN"
