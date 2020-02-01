**Introduction to Autonomous Cloud with Keptn** workshop given @[Dynatrace Perform 2020](https://https://www.dynatrace.com/perform-vegas//)

At this point, we should have our initial setup complete. We should have a GKE cluster that is monitored by Dynatrace, and the full complement of Keptn services. 

# Excercise 1: Onboarding the Simplenode service

1. In this exercise, we will create a Keptn project, which is a structural element that allows organizing your services. A project is stored as a repository and contains branches representing the multi-stage environment (e.g., dev, staging, and production stage). In other words, the separation of stage configurations is based on repository branches. To describe the stages, a `shipyard.yaml` file is needed that specifies the name, deployment strategy, test strategy, and remediation strategy.

2. After creating a project, the Keptn CLI allows creating new Keptn-managed services (i.e., to *onboard* services into Keptn). The onboarded services are organized in the before created project.

## Create project Simpleproject 

For creating a project, this exercise relies on the `shipyard.yaml` file as shown below. This file is available on your Bastion host.

```yaml
stages:
  - name: "dev"
    deployment_strategy: "direct"
    test_strategy: "functional"
  - name: "staging"
    deployment_strategy: "blue_green_service"
    test_strategy: "performance"
  - name: "production"
    deployment_strategy: "blue_green_service"
    remediation_strategy: "automated"
```

* Please make sure that you are in the correct folder on your bastion host: 

```console
cd ~/getting-started/keptn-onboarding
```

* Execute the following command to create the project based on the `shipyard.yaml` file: 

```console
keptn create project simpleproject --shipyard=./shipyard.yaml --git-user=GIT_USER --git-token=GIT_TOKEN --git-remote-url=GIT_REMOTE_URL
```    
    
## Onboard service Simplenode

At this point, the project does not contain any deployable service yet. 

* Execute the following command to onboard the **simplenode** service to your project: 

```
keptn onboard service simplenode --project=simpleproject --chart=./simplenode
```

## Result

Now, a project is created and the **simplenode** service is onboarded. 

:mag: Let's check out the configuration files that Keptn has generated in your Git repository. > **Go to your Git repository**.

:heavy_check_mark: For each stage we have defined in our `shipyard.yaml`, there will be a branch that holds the configuration for the application running in that stage. 

:heavy_check_mark: Each change made to the configuration will be made through a git commit, which will make it easy to track every change that has been done to the configuration.

---

:arrow_forward: [Next Lab: Deploying the simplenode service](../02_Deploying_simplenode_service)

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)