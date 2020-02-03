**Introduction to Autonomous Cloud with Keptn** workshop given @[Dynatrace Perform 2020](https://https://www.dynatrace.com/perform-vegas//)

In the previous lab, you have learned how Keptn can be used for continuous delivery including quality gates.
However, even a deployed service can have issues that only arise in production and, hence, cannot be checked with a quality gate.
For example, an unhealthy state of a service can be caused by untested parts of its implementation that cause issues 
by an overload, or by a wrong configuration.

# Exercise 4: Automatic remediation actions with Keptn

In this exercise, you use the deployed **simplenode** service, which passed the quality gates.
However, this version of the **simplenode** service has a hidden flag that causes the service to fail frequently while it is in production. 
Dynatrace will detect this problem and will send a problem event to Keptn.
Using predefined remediation actions, you can tell Keptn how to automatically remediate this problem. 
By this, you can implement a self-healing mechanism for the **simplenode** service.

## Configure Remediation Actions

Keptn allows configuring remediation actions for different problem types.
Therefore, Keptn uses a so-called `remediation.yaml` file, which contains a list of problems and their corresponding remediation actions.
The `remediation.yaml` file used in this exercise looks as follows:

```yaml
remediations:
- name: Response time degradation
  actions:
  - action: scaling
    value: +2
```

**Note:** By using this file, Keptn will react to problems that cause a **Response time degradation** with scaling up the number of replicas running your service. In this case, the replica count will be increased by 2 pods. 

* Please make sure that you are in the correct folder on your Bastion host:

  ```console
  cd ~/getting-started/keptn-onboarding
  ```

* To configure the remediation action for Keptn, execute: 

  ```console
  keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=remediation.yaml
  ```

* Additionally, add another SLO file for your `production` stage to verify if your remediation action has been successful. Execute the following command: 

  ```console
  keptn add-resource --project=simpleproject --service=simplenode --stage=production --resource=slo-self-healing.yaml --resourceUri=slo.yaml
  ```

## Configure Dynatrace Problem Detection

For the sake of the workshop, you will configure Dynatrace to detect problems based on fixed thresholds. 

* In your Dynatrace Tenant, go to **Settings > Anomaly detection > Services**.

* Within this menu, select the option **Detect response time degradations using fixed thresholds**, set the limit to **1000ms**, and select **Medium** for the sensitivity. Please take a look at the screenshot below:

  ![](../images/anomaly_detection.png)

As a last configuration step, you will disable the *Frequent Issue Detection* to make the demo repeatable.

* In your Dynatrace Tenant, go to **Settings > Anomaly detection > Frequent issue detection**, disable all switches found in this menu, and click on **Save changes**:

  ![](../images/disable-fid.png)

## Generate User Traffic for the simplenode service

Next, you will generate load on your deployed **simplenode** service by using a prepared script.

* Switch into the folder containing the load generator by executing the following command in your Bastion host:

  ```console
  cd ~/getting-started/load-generation/bin
  ```

* To trigger the load generator script, execute:
  ```console
  ./loadgenerator-linux "http://simplenode.simpleproject-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')"/api/cpuload
  ```

## Follow the executed Remediation Action

* Navigate to your Dynatrace Tenant, go to **Transactions & services**, and select the Management Zone **Keptn: simpleproject production**. 

  ![](../images/services_dt.png)

* Here, you should see a service instance containing the `primary` deployment of your **simplenode** service:

  ![](../images/service_primary.png)

* Select this service, and you will be directed to the overview screen. On this screen, click on the *Response time* button:

  ![](../images/service_overview.png)

* This will direct you to a screen showing you a time series chart for the response time of your service:

  ![](../images/response_time_series.png)

* After some time, a problem will be detected in Dynatrace due to the increase in response time caused by the heavy load you just created: 

  ![](../images/dt_problem.png)

* When this happens, a problem event will be 
sent to Keptn, which will trigger the `scaling` remediation action that you have defined in the `remediation.yaml` file.
Follow the events in the Keptn's Bridge:

  ![](../images/bridge_self_healing.png)

* After the remediation action has been executed, 3 pods are serving the **simplenode** service:

    ```
    $ kubectl get pods -n simpleproject-production
    simplenode-primary-6dbd854774-9vhrz   2/2     Running   0          109m
    simplenode-primary-6dbd854774-kd58t   2/2     Running   0          12m
    simplenode-primary-6dbd854774-mhbnb   2/2     Running   0          12m
    ```

# Result

:heavy_check_mark: As you can see in the Keptn's Bridge, the problem event triggerd a remediation action (i.e., a scale up of the replicas of your service). 

:heavy_check_mark: After the new replicas have been deployed, Keptn will wait for a certain amount of time (10 minutes), before triggering an evaluation of the objectives defined in your `slo.yaml` file for the production stage. 

:heavy_check_mark: The evaluation of your *Service Level Objectives* should be successful at this point since the load is now split among three instances of your service. 

:heavy_check_mark: Eventually, the problem will also be closed in Dynatrace.

:heavy_check_mark: In addition to automatically performing the remediation, Keptn also informs Dynatrace about the actions taken during this remediation process. You can verify this by navigating to the service overview and checking the events related to that service:

  ![](../images/dt_service_events.png)

:heavy_check_mark: You can also verify the remediation action by investigating the time series chart for the response time of your service. In this chart you will see a decrease in response time starting at the moment where Keptn deployed the additional instances of your service:

  ![](../images/dt_problem_closed.png)

---

[Previous Step: Exploring quality gates](../03_Exploring_quality_gates) :arrow_backward:

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)

