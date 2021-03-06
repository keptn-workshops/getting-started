**Introduction to Autonomous Cloud with Keptn** workshop given @[Dynatrace Perform 2020](https://https://www.dynatrace.com/perform-vegas//)

At this point, the **simplenode** service has been deployed for the first time and the quality gate in the `staging` stage has been activated by providing an SLO file.

# Exercise 3: Exploring Keptn's Quality Gates

When developing an application, sooner or later you need to update a service in a production environment. To conduct this in a controlled manner and without impacting end-user experience, the quality of the new service has to be ensured and adequate deployment strategies must be in place. For example, a blue-green deployment is a well-known strategy to roll out a new service version by also keeping the previous service version available if something goes wrong.

1. In this exercise, you will deploy a version of the **simplenode** service that has a slower response time compared to the previous version. Since you have activated the quality gate, the weak performance gets detected and the quality gate will prevent a promotion of this artifact to the `production` environment.  

1. Finally, you will again deploy a version of the **simplenode** service which fixed the response time issue and, eventually, will pass the quality gate.

## Deployment of a SLOW Implementation of the simplenode Service

To demonstrate the benefits of having quality gates in place, you will now deploy a version of the **simplenode** service with terribly slow response time. 

* To trigger the deployment of this version, please execute:

    ```console
    keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/keptnexamples/simplenodeservice --tag=5.0.2
    ```

### Promotion from Dev to Staging

After some time, this new version will be deployed into the `dev` stage. If you look into the `shipyard.yaml` file that you used to create the `simpleproject` project, you will see that only functional tests are executed in this stage. 

This means that even though the version has a slow response time, it will be promoted into the `staging` environment because it is working as expected on a functional level. 

:mag: You can verify the deployment of the new version into `staging` by navigating to the URL of the service:

```console
echo http://simplenode.simpleproject-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

### Keptn's Quality Gate detects Performance leak - NO Promotion to Production!

As soon as this version has been deployed into the `staging` environment, the performance tests are executed.
When those are finished, Keptn will evaluate them against the defined *Service Level Objectives* (SLOs) using Dynatrace as *Service Level Indicator* (SLI) provider. 

:boom: At this point, Keptn detects that the response time of the service is too high and marks the evaluation of the performance tests as `failed`.

As a result, the new artifact will not be promoted into the `production` stage. Additionally, the traffic routing within the `staging` stage will be automatically updated to send requests to the previous version of the service. 
   
:mag: You can explore the reason for the failed evaluation in Keptn's Bridge and in Dynatrace:

**a) Keptn's Bridge**

The Keptn's Bridge gives you a detailed view of the evaluation result (i.e., all SLIs).
This includes the response time, which caused the evaluation to fail:

![](../images/bridge_quality_gate.png)

**b) Dynatrace**

Dynatrace detected an increase of the *Response time* for the `SimpleNodeJsService` in the `staging` environment:

![](../images/dynatrace_response_time.png)


## Deployment of a new version of the simplenode service, which fixes the response time issue 

* Finally, deploy a new version of the **simplenode** service, which contains a fix for the response time issue.
This version eventually will pass the quality gate:

    ```console
    keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/keptnexamples/simplenodeservice --tag=5.0.4
    ```

## Result

The slow version was not promoted to the production environment because of the active **Keptn's Quality Gate** in place.

---

[Previous Step: Deploying simplenode service](../02_Deploying_simplenode_service) :arrow_backward: :arrow_forward: [Next Step: Automatic remediation](../04_Automatic_remediation)

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)