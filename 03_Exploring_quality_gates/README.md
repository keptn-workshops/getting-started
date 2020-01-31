**Introduction to Autonomous Cloud with Keptn** workshop given @[Dynatrace Perform 2020](https://https://www.dynatrace.com/perform-vegas//)

At this point, we the simplenode service deployed for the first time. 

# Excercise 3: Deployment of a slow implementation of the Simplenode service

To demonstrate the benefits of having quality gates, we will now deploy a version of the simplenode service with a terribly slow response time. 

* To trigger the deployment of this version, please execute the following command on your machine:

```console
keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=2.0.0
```

## Behaviour in Dev - Promotion from Dev to Staging

After some time, this new version will be deployed into the `dev` stage. If you look into the `shipyard.yaml` file that you used to create the `simpleproject` project, you will see that in this stage, only functional tests are executed. 

This means that even though the version has a slow response time, it will be promoted into the `staging` environment because it is working as expected on a functional level. 

:mag: You can verify the deployment of the new version into `staging` by navigating to the URL of the service in your browser using the following URL:

```console
echo http://simplenode.simpleproject-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

## Quality Gate detects Performance leak - NO Promotion to Production!

As soon as this version has been deployed into the `staging` environment, 
thest performance tests for this service are executed. When those are finished, Keptn will evaluate them using Dynatrace as a data source. 

:boom: At this point, it will detect that the response time of the service is too high and mark the evaluation of the performance tests as `failed`.

As a result, the new artifact will not be promoted into the `production` stage. Additionally, the traffic routing within the `staging` stage will be automatically updated in order to send requests to the previous version of the service. 

## Deploy again the previous good version 

```
keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=1.0.0
```

# Result

Production is safe, with the Quality Gate in the staging stage. We have seen that a service version with a bad performance will not be promoted to the production stage. 

---

[Previous Step: Deploying simplenode service](../02_Deploying_simplenode_service) :arrow_backward: :arrow_forward: [Next Step: Automatic remediation](../04_Automatic_remediation)

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)