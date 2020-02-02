**Introduction to Autonomous Cloud with Keptn** workshop given @[Dynatrace Perform 2020](https://https://www.dynatrace.com/perform-vegas//)

At this point, you have a Keptn project created and the **simplenode** service onboarded to the project.

# Exercise 2: Deploying the simplenode Service

In this exercise, you will configure tests and activate Keptn's quality gate.
Afterwards, you will trigger the first deployment of the **simplenode** service. 

<!-- ## Configure Dynatrace 

You can use Keptn to automatically generate a Dynatrace dashboard and management zones for your *simplenode* project. 

* To create a Dynatrace **Dashboard** and **Management zones**, execute:

    ```console
    keptn configure monitoring dynatrace --project=simpleproject
    ```

* Afterwards, you can view your generated Dashboard under: `https://<YOUR_DYNATRACE_TENANT>/#dashboards` -->

## Configure Tests

Your continuous delivery process requires functional tests for the `dev` environment and performance tests for the `staging` environment. (**Note:** In this workshop, JMeter is used for testing.)

* Please make sure that you are in the correct folder on your Bastion host: 

    ```console
    cd ~/getting-started/keptn-onboarding
    ```

* To add a **functional test** to the `dev` stage, execute: 

    ```console
    keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
    ```
<!--
* To active **load tests** in *dev* stage, execute: 
```
keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/load.jmx
```

* To active **functional tests** in *staging* stage, execute: 
```
keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
```
-->

* To add a **load test** to the `staging` stage, execute: 

    ```console
    keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx
    ```

## Activate Keptn's Quality Gate

During the deployment process, the artifacts have to pass a quality gate in the `staging` environment before it is promoted to the `production` environment. 
This quality gate is specified as *Service Level Objectives* (SLOs), i.e., in a so-called `slo.yaml` file.
To learn more about the `slo.yaml` file, go to [Specifications for Site Reliability Engineering with Keptn](https://github.com/keptn/spec/blob/0.1.2/sre.md).

* To add the **SLO** file to the `staging` stage, execute: 

    ```console
    keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=slo.yaml
    ```

## Trigger the first Deployment

* To trigger your first deployment of the **simplenode** service, execute:
   
    ```console
    keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/keptnexamples/simplenodeservice --tag=5.0.1
    ```
   
:mag: As the deployment runs you can watch the progress in the Keptn's Bridge and in Dynatrace:

**a) Keptn's Bridge**

* Open your Keptn's Bridge and select project: **simpleproject** > service: **simplenode**
* Then click on the **Configuration change** event. 

![](../images/keptn_bridge_events.png)

**b) Dynatrace**

* Navigate to your Dynatrace Tenant, go to **Transactions and Services** and select the Management Zone **Keptn: simpleproject staging**.

* **Note:** Keptn pushes events to those Dynatrace service entities that match the `keptn_project`, `keptn_service`, `keptn_stage`, and `keptn_deployment` tags:
![](../images/dynatrace_events.png)

## Result

After a couple of minutes, the **simplenode** is deployed in your Kubernetes cluster. You can retrieve the URLs for the **simplenode** service for each stage as follows:

:heavy_check_mark: `dev` stage: 
```console
echo http://simplenode.simpleproject-dev.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

:heavy_check_mark: `staging` stage: 
```console
echo http://simplenode.simpleproject-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

:heavy_check_mark: `production` stage: 
```console
echo http://simplenode.simpleproject-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

:mag: Navigate to the URLs to inspect your **simplenode** service. In the `dev`, `staging`, and `production` environment, you should see the following page:

![](../images/simplenode-production.png)

---

[Previous Step: Onboarding simplenode service](../01_Onboarding_simplenode_service) :arrow_backward: :arrow_forward: [Next Step: Exploring quality gates](../03_Exploring_quality_gates)

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)