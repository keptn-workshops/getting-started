#!/bin/sh
keptn auth --endpoint=https://api.keptn.$(kubectl get cm -n keptn keptn-domain -ojsonpath={.data.app_domain}) --api-token=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)

keptn create project simpleproject --shipyard=./shipyard.yaml
keptn onboard service simplenode --project=simpleproject --chart=./simplenode

# NEW: configure SLI provider via configMaps
kubectl apply -f lighthouse-config.yaml

keptn configure monitoring dynatrace --project=simpleproject

# Add Jmeter test files
keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx

keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx

#keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
#keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx

# add SLO file
keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=slo.yaml

keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=slo-self-healing.yaml --resourceUri=slo.yaml
keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=remediation.yaml



keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=1.0.0
