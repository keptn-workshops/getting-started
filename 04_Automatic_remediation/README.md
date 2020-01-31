## Self-healing in action

Now it's time to deploy our next version of the simplenode service. This version meets all SLOs during the performance tests,
but there is a hidden flag that causes the service to fail frequently while it is in production. This will be detected by Dynatrace, which will send a problem event to Keptn.
Using our remediation.yaml file, we can tell Keptn how to automatically remediate problems of a certain type so we can keep the lights up in production.

### Upload remediation file

To tell Keptn what to do in case of a detected problem with our service, we will use a `remediation.yaml` file that looks as follows:

```yaml
remediations:
- name: Response time degradation
  actions:
  - action: scaling
    value: +2
```

By using this file, Keptn will react to problems that cause a **Response time degradation** (that might be caused by an increasing load to our service) with scaling up the number
of replicas running our service. In this case, we will increase the replica count by 2 pods. To stay in line with the GitOps approach, we will store this file in the Git repository that holds
the configuration for our service. This can be done using the following command:

```
cd ~/getting-started/keptn-onboarding
keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=remediation.yaml
```

We can also add another SLO file (in this case to our production stage) to verify if our remediation action has been successful:

```
keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=slo-self-healing.yaml --resourceUri=slo.yaml
```

### Configure Dynatrace Problem Detection

For the sake of the workshop, we will configure Dynatrace to detect Problems based on fixed thresholds. To do so, navigate to your Dynatrace Tenant in your browser,
and go to *Settings -> Anomaly Detection -> Services*.

Within this menu, select the option **Detect response time degradations using fixed thresholds**, set the limit to **1000ms**, and select **Medium** for the sensitivity (see the screenshot below).

![](../images/anomaly_detection.png)

As a last configuration step, we will disable the Frequent Issue Detection to make the demo more reproducible. To do so, go to **Settings -> Anomaly Detection -> Frequent Issue Detection**,
and disable all switches found in this menu:

![](../images/disable-fid.png)

### Deploy a new version

To deploy the new artifact, we once again use the Keptn CLI to start the deployment process:

```
keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=4.0.0
```

After the new artifact has been deployed into production, we will generate some load on our newly deployed version. To do so, execute the following commands
in your shell:

```
cd ~/getting-started/load-generation/bin
./loadgenerator-linux "http://simplenode.simpleproject-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')"/api/cpuload
```

Next, navigate to your Dynatrace Tenant, go to **Transactions and Services**, and select the Management Zone **Keptn: simpleproject production**. 

![](../images/services_dt.png)

Here you should see a service instance containing the `primary` deployment of our sample service:

![](../images/service_primary.png)

Select this service, and you will be directed to the overview screen. On this screen, click on the Response time button:

![](../images/service_overview.png)

This will direct you to a screen showing you a time series chart for the response time of our service:

![](../images/response_time_series.png)

After some time, a problem will be detected in Dynatrace, due to the increase in response time caused by the heavy load we just created: 

![](../images/dt_problem.png)

When this happens, a problem event will be 
sent to Keptn, which will trigger a remediation action that we have defined in the `remediation.yaml` file. You can get an overview of the actions taken during that remediation using the Keptn's bridge:

![](../images/bridge_self_healing.png)

As you can see in the screenshot, the problem event caused a remediation (scaling up the replicas of our service). After the new replicas have been deployed, Keptn will wait for a certain amount of time (10 minutes), before triggering an
evaluation of the metrics in our `slo.yaml´ file. The evaluation of our service level objectives should be successful at this point since the load is now split among three instances of our service.
Eventually, the Problem will also be closed in Dynatrace.

In addition to automatically performing the remediation, Keptn also informs Dynatrace about the actions taken during this process. You can verify this by navigating to the 
Service overview, and checking the events related to that service:

![](../images/dt_service_events.png)

We can also verify the remediation action by investigating the time series chart for the response time of our service. 
In this chart you will see a decrease in response time starting at the moment where Keptn deployed the additional instances of our service:

![](../images/dt_problem_closed.png)

[Previous Step: Exploring quality gates](../03_Exploring_quality_gates) :arrow_backward:

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)