#!/bin/bash

echo ""
echo "============================================================="
echo "About to install the Notification Service"
echo "============================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

SLACK_URL=$1

rm -f ./manifests/gen/notification-service.yaml
cat ./manifests/notification-service.yaml | \
  sed 's~SLACK_URL_PLACEHOLDER~'"$DOMAIN"'~' > ./manifests/gen/notification-service.yaml

kubectl apply -f ./manifests/gen/notification-service.yaml
