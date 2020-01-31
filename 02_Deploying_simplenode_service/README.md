
1. Now that the service has been onboarded, we can use Keptn to automatically generate a Dynatrace dashboard and management Zones for our project. To do so, execute

    ```
    keptn configure monitoring dynatrace --project=simpleproject
    ```

    Afterwards, you can view your generated dashboard under https://<YOUR_DYNATRACE_TENANT>/#dashboards

1. At this point, it is time to set up our test files (we will use jmeter for testing), and our Service Level Objectives. After all, we do not want to blindly send artifacts into production, but want to ensure that our performance criteria are met:

   ```
   keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
   keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/load.jmx
   
   keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
   keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx
   
   keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=slo.yaml
   ```
   
1. Now, we will tell Keptn to use the **dynatrace-sli-service** as a value provider for our Service Level Indicators. We will do this using a ConfigMap:

   ```
   kubectl apply -f lighthouse-config.yaml
   ```
1. We are now ready and can run our first deployment
   
   ```
   keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=1.0.0
   ```
   
   As the deployment runs you can watch the progress
   
   **a) through the Keptn's bridge**
   ![](../images/keptn_bridge_events.png)
   
   **b) through Dynatrace events**
   The Dynatrace Service has pushed events to those Dynatrace Service entities that match the `keptn_project`, `keptn_service`, `keptn_stage` and `keptn_deployment` tags:
   ![](../images/dynatrace_events.png)

# View the simplenode service

To make the simplenode service accessible from outside the cluster, and to support blue/green deployments, Keptn automatically creates Istio VirtualServices that direct requests to certain URLs to the correct service instance. You can retrieve the URLs for the simplenode service for each stage as follows:

```
echo http://simplenode.simpleproject-dev.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
echo http://simplenode.simpleproject-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
echo http://simplenode.simpleproject-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

Navigate to the URLs to inspect your simplenode service. In the production namespace, you should receive an output similar to this:

![](../images/simplenode-production.png)


[Previous Step: Onboarding simplenode service](../01_Onboarding_simplenode_service) :arrow_backward: :arrow_forward: [Next Step: Exploring quality gates](../03_Exploring_quality_gates)

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)