## Deployment of a slow implementation of the simplenode service

To demonstrate the benefits of having quality gates, we will now deploy a version of the simplenode service with a terribly slow response time. To trigger the deployment of this version, please execute the following command on your machine:

```
keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=2.0.0
```

After some time, this new version will be deployed into the `dev` stage. If you look into the `shipyard.yaml` file that you 
used to create the `simpleproject` project, you will see that in this stage, only functional tests are executed. 
This means that even though the version has a slow response time, it will be promoted into the `staging` environment 
because it is working as expected on a functional level. You can verify the deployment of the new version into `staging` 
by navigating to the URL of the service in your browser using the following URL:

```
echo http://simplenode.simpleproject-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```


As soon as this version has been deployed into the `staging` environment, 
the `jmeter-service` will execute the performance tests for this service. 
When those are finished, the `lighthouse-service` will evaluate them using 
Dynatrace as a data source. At this point, it will detect that the response 
time of the service is too high and mark the evaluation of the performance tests as `failed`.

As a result, the new artifact will not be promoted into the `production` stage. 
Additionally, the traffic routing within the `staging` stage will be automatically 
updated in order to send requests to the previous version of the service. 


## Optional: Try to modify your SLOs

To become more familiar with the definition of Service Level Objectives, try to modify the SLIs defined in the **slo.yaml** file.
For example, you can either change the values, add additional criteria for certain SLIs, or you can add your own SLIs! As a reference,
you can use the documentation found in the [Keptn Spec repo](https://github.com/keptn/spec/blob/0.1.1/sre.md#service-level-objectives-(slo)),
or feel free to ask our instructors!

When you have edited your SLOs, use 

```
keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=slo.yaml
```

to tell Keptn to use this new version of your **slo.yaml** for future evaluations.
To see how the new SLOs affect the evaluation, trigger a new deployment with 

```
keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=1.0.0
```

## Optional: Install notification-service

You can use the [notification-service](https://github.com/keptn-contrib/notification-service) to always stay informed about what is going on with your Keptn projects.
To install it, execute the following commands (you will receive the `SLACK_URL` during the workshop - please ask an instructor):

```
cd ~/getting-started/keptn
./installNotificationService.sh <SLACK_URL>
```

After the service has been installed, you will be able to view all Keptn Events in the Slack Workspace we have prepared for this HOT Day (please ask the instructors for an invite link to join the channel).

[Previous Step: Deploying simplenode service](../02_Deploying_simplenode_service) :arrow_backward: :arrow_forward: [Next Step: Automatic remediation](../04_Automatic_remediation)

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)