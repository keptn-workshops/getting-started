# keptn-hotday2020
Instructions for the HoT workshop "Intro to ACM with Keptn" given @Dynatrace Perform 2020

# Overview
In this workshop, you will get hands-on experience with the open source framework [keptn](https://keptn.sh), and see how it can help you to manage your cloud-native applications on Kubernetes

# Pre-requisites

## 1. Accounts

1. Dynatrace - Assumes you will use a [trial SaaS dynatrace tenant](https://www.dynatrace.com/trial). You will get your Dynatrace Tenant credentials during the workshop.
1. GitHub Account (optional)
1. GKE Cluster - you will get the access information during the workshop


## 2. Git Repo (optional, but recommended)
Keptn installs its own Git. In order to modify SLIs & SLOs that are managed by keptn we will define a remote git upstream. Feel free to use GitHub, GitLab, Bitbucket or any other Git service. What you need are these 3 things
1. **GIT_REMOTE_URL**: Create a Remote Git Hub Repo that includes a Readme.md
2. **GIT_USER**: Your git user to login
3. **GIT_TOKEN**: A token for your git that allows keptn to push updates to that repo

You can create the GitHub Token as follows:

![](images/github_repo_create.png)

## 3. Dynatrace Token
This example shows keptn quality gates based on Dynatrace metrics using the new [Dynatrace Metrics v2 API](https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/environment-api/metric/).
Hence you need Dynatrace that instruments the services you want to validate SLOs against. In order for keptn to automate that validation we need two things:
1. **Dynatrace URL**: Thats e.g: https://abc12345.dynatrace.live.com (for SaaS) or your https://managedservice/e/yourenvioronment (for Managed)
2. **Dynatrace API Token**: Please create a Dynatrace API token with access to timeseries as well as read & write configuration (for my advanced service metric SLIs)
3. **Dynatrace PAAS API Token**: Please create a Dynatrace PaaS token which will be used to rollout the OneAgent on your EKS cluster

## 4. Tools

On the bastion host you are using during the workshop, all required tools (i.e. **kubectl** and **keptn**) are already installed

## Environment Setup

## TODO: Explain how to access shellinabox and connect to GKE Cluster

Now it's time to set up your workshop environment. 
During the setup, you will need the following values. 
We recommend to copy the following lines into an editor, 
fill them out and keep them as a reference for later:

```
Dynatrace Host Name (e.g. abc12345.live.dynatrace.com):
Dynatrace API Token:
Dynatrace PaaS Token:
GitHub User Name:
GitHub Personal Access Token:
GitHub User Email:
GitHub Organization:
```

### Install Keptn

This will install the Keptn control plane and uniform components into your cluster.  The install will take 5-10 minutes to perform.
To start the installation, please execute

```
keptn install --platform=gke
```

### Install Dynatrace
To install Dynatrace, we will use the `dynatrace-service` that can be installed as an add-on for Keptn. This service will do the following things:

    - Deploy the Dynatrace OneAgent to gain monitoring insights for your entire cluster
    - Create Auto-Tagging rules which will be used by Keptn
    - Set up customized problem notifications that can be sent to and interpreted by Keptn.
    - Automatically create Management Zones for your Keptn projects
    - Automatically create Dashboards for your Keptn projects
    
To perform correctly, the dynatrace-service requires the **Dynatrace Tenant**, the **API Token**, and the **PaaS Token**. To store these attributes in the cluster as a Kubernetes secret, 
perform the following command after replacing the placeholders for :

```
kubectl -n keptn create secret generic dynatrace --from-literal="DT_API_TOKEN=<DT_API_TOKEN_PLACEHOLDER>" --from-literal="DT_TENANT=<DT_TENANT_PLACEHOLDER>" --from-literal="DT_PAAS_TOKEN=<DT_PAAS_TOKEN_PLACEHOLDER>"
```

When the secret has been created successfully, you can install the dynatrace-service:

```
kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/dynatrace-service/master/deploy/manifests/dynatrace-service/dynatrace-service.yaml
```

When the service has been created, wait until the `dynatrace-sercvice` pod in the `keptn` namespace has the status `Running`:

```
$ kubectl get pods -n keptn -w |grep dynatrace
dynatrace-service-67bc686bc-vtpnx                                 1/1     Running   0          46h
dynatrace-service-distributor-6d6d6c5478-krcws                    1/1     Running   0          47h
```

Afterwards, execute the command 

```
keptn configure monitoring dynatrace
```

This will instruct the dynatrace service to install the Dynatrace OneAgent on your cluster. Now your cluster is monitored by Dynatrace!

### Install Dynatrace SLI Service

During the workshop we will use quality gates to ensure only artifacts that meet our performance requirements are pushed through to production.
We will retrieve the relevant Service Level Indicator values via the Dynatrace SLI Service that grabs those values from the new Dynatrace metrics API.
To install the service, use `kubectl` to deploy it into your cluster:

```
kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/dynatrace-sli-service/0.2.0/deploy/service.yaml
kubectl apply -f https://github.com/keptn-contrib/dynatrace-sli-service/raw/0.2.0/deploy/distributor.yaml
```

## 5)  Expose Keptn's Bridge

The [keptn’s bridge](https://keptn.sh/docs/0.6.0/reference/keptnsbridge/) provides an easy way to browse all events that are sent within keptn and to filter on a specific keptn context. When you access the keptn’s bridge, all keptn entry points will be listed in the left column. Please note that this list only represents the start of a deployment of a new artifact and, thus, more information on the executed steps can be revealed when you click on one event.

<img src="images/bridge-empty.png" width="500"/>

In the default installation of Keptn, the bridge is only accessible via `kubectl port-forward`. To make things easier for workshop participants, we will expose it by creating a public URL for this component.

```
cd keptn
./exposeBridge.sh
```
You should now be able to access the Keptns Bridge via the URL shown in the exposeBridge.sh output
![](images/expose_bridge.png)


# Onboarding the simplenode service

Now that your environment is up and running and monitored by Dynatrace, you can proceed with onboarding the simplenode application into your cluster.
To do so, please follow these instructions:

1. First, we will create a new project called **simpleproject** that will contain our **simplenode** service. Using the **shipyard.yaml** file, we will define our stages (dev, staging, production) we want to use for this project:

    Create a new project without Git upstream:
    ```console
    keptn create project simpleproject --shipyard=./shipyard.yaml
    ```

    <details><summary>Optional: Create a new project with Git upstream</summary>
    <p>

    To configure a Git upstream for this workshop, the Git user (`--git-user`), an access token (`--git-token`), and the remote URL (`--git-remote-url`) are required. If a requirement is not met, go to [select Git-based upstream](../../manage/project/#select-git-based-upstream) where instructions for GitHub, GitLab, and Bitbucket are provided.

    ```console
    keptn create project sockshop --shipyard=./shipyard.yaml --git-user=GIT_USER --git-token=GIT_TOKEN --git-remote-url=GIT_REMOTE_URL
    ```
    </p>
    </details>

1. At this point, the project does not contain any deployable services yet. Therefore, we now have to onboard our **simplenode** service:

    ```
    keptn onboard service simplenode --project=simpleproject --chart=./simplenode
    ```
   
1. Now the service is onboarded, and you can view the configuration files that Keptn has generated in your GitHub repository that you have set up earlier. For each stage we have defined in our shipyard.yaml, there will be a branch that holds the configuration for the 
application running in that stage. Each change made to the configuration will be made through a git commit, which will make it easy to track every change that has been done to the configuration!

1. Now that the service has been onboarded, we can use Keptn to automatically generate a Dynatrace dashboard and management Zones for our project. To do so, execute

```
keptn configure monitoring dynatrace --project=simpleproject
```

Afterwards, you can view your generated dashboard under https://<YOUR_DYNATRACE_TENANT>/#dashboards

1. At this point, it is time to set up our test files (we will use jmeter for testing), and our Service Level Objectives. After all, we do not want to blindly send artifacts into production, but want to ensure that our performance criteria are met:

   ```
   keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
   keptn add-resource --project=simpleproject --service=simplenode --stage=dev --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx
   
   keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
   keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx
   
   keptn add-resource --project=simpleproject --service=simplenode --stage=staging --resource=slo.yaml
   ```
   
1. Now, we will tell Keptn to use the **dynatrace-sli-service** as a value provider for our Service Level Indicators. We will do this using a ConfigMap:

   ```
   kubectl apply -f lighthouse-config.yaml
   ```
1. We are now ready and can run a new deployment
   
   ```
   keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=1.0.0
   ```
   
   As the deployment runs you can watch the progress
   
   **a) through the keptns bridge**
   ![](images/keptn_bridge_events.png)
   
   **b) through Dynatrace events**
   The Dynatrace Service has pushed events to those -Dynatrace Service entities that match the keptn_project, keptn_service, keptn_stage and keptn_deployment tags:
   ![](images/dynatrace_events.png)

# View the simplenode service

To make the simplenode service accesible from outside the cluster, and to support blue/green deployments, keptn automaticalliy creates Istio VirtualServices that direct requests to certain URLs to the correct service instance. You can retrieve the URLs for the simplenode service for each stage as follows:

```
echo http://simplenode.simpleproject-dev.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
echo http://simplenode.simpleproject-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
echo http://simplenode.simpleproject-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

Navigate to the URLs to inspect your simplenode service. In the production namespace, you should receive an output similar to this:

![](images/simplenode-production.png)

## Deployment of a slow implementation of the simplenode service

To demonstrate the benefits of having quality gates, we will now deploy a version of the simplenode service with a terribly slow response time. To trigger the deployment of this version, please execute the following command on your machine:

```
keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=2.0.0
```

After some time, this new version will be deployed into the `dev` stage. If you look into the `shipyard.yaml` file that you 
used to create the `simpleproject` project, you will see that in this stage, only functional tests are executed. 
This means that even though version has a slow response time, it will be promoted into the `staging` environment, 
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
cd keptn
./installNotificationService.sh <SLACK_URL>
```

After the service has been installed, you will be able to view all Keptn Events in the Slack Workspace we have prepared for this HOT Day (please ask the instructors for an invite Link to join the channel)

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
of replicas running our service. In this case we will increase the replica count by 2 pods. To stay in line with the GitOps approach, we will store this file in the Git repository that holds
the configuration for our service. This can be done using the following command:

```
cd keptn-onboarding
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

![](images/anomaly_detection.png)

As a last configuration step, we will disable the Frequent Issue Detection to make the demo more reproducable. To do so, go to **Settings -> Anomaly Detection -> Frequent Issue Detection**,
and disable all switches found in this menu:

![](images/disable-fid.png)

### Deploy a new version

To deploy the new artifact, we once again use the keptn CLI to start the deployment process:

```
keptn send event new-artifact --project=simpleproject --service=simplenode --image=docker.io/bacherfl/simplenodeservice --tag=4.0.0
```

After the new artifact has been deployed into production, we will generate some load on our newly deployed version. To do so, execute the following commands
in your shell:

```
cd load-generation/bin
./loadgenerator-linux "http://simplenode.simpleproject-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')"/api/cpuload
```

Next, navigate to your Dynatrace Tenant, go to **Transactions and Services**, and select the Management Zone **Keptn: simpleproject production**. 

![](images/services_dt.png)

Here you should see a service instance containing the `primary` deployment of our sample service:

![](images/service_primary.png)

Select this service, and you will be directed to the overview screen. On this screen, click on the Response time button:

![](images/service_overview.png)

This will direct you to a screen showing you a time series chart for the response time of our service:

![](images/response_time_series.png)

After some time, a problem will be detected in Dynatrace, due to the increase in response time caused by the heavy load we just created: 

![](images/dt_problem.png)

When this happens, a problem event will be 
sent to Keptn, which will trigger a remediation action that we have defined in the `remediation.yaml` file. You can get an overview of the actions taken during that remediation using the Keptn's bridge:

![](images/bridge_self_healing.png)

As you can see in the screenshot, the problem event caused a remediation (scaling up the replicas of our service). After the new replicas have been deployed, Keptn will wait for a certain amount of time (10 minutes), before triggering an
evaluation of the metrics in our `slo.yaml´ file. The evaluation of our service level objectives should be successful at this point, since the load is now split among three instances of our service.
Eventually, the Problem will also be closed in Dynatrace.

In addition to automatically performing the remediation, Keptn also informs Dynatrace about the actions taken during this process. You can verify this by navigating to the 
Service overview, and checking the events related to that service:

![](images/dt_service_events.png)

We can also verify the remediation action by investigating the time series chart for the response time of our service. 
In this chart you will se a decrease in response time starting at the moment where Keptn deployed the additional instances of our service:

![](images/dt_problem_closed.png)








