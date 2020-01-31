# Onboarding the simplenode service

Now that your environment is up and running and monitored by Dynatrace, you can proceed with onboarding the simplenode application into your cluster.
To do so, please follow these instructions:

1. First, we will create a new project called **simpleproject** that will contain our **simplenode** service. Using the **shipyard.yaml** file, we will define our stages (dev, staging, production) we want to use for this project:

    <details><summary>Option A: Create a new project with Git upstream</summary>
    <p>
    To configure a Git upstream for this workshop, the Git user (`--git-user`), an access token (`--git-token`), and the remote URL (`--git-remote-url`) are required. If a requirement is not met, go to [select Git-based upstream](https://keptn.sh/docs/0.6.0/manage/project/#select-git-based-upstream) where instructions for GitHub, GitLab, and Bitbucket are provided.

    ```console
    cd ~/getting-started/keptn-onboarding
    keptn create project simpleproject --shipyard=./shipyard.yaml --git-user=GIT_USER --git-token=GIT_TOKEN --git-remote-url=GIT_REMOTE_URL
    ```    
    </p>
    </details>
    

    <details><summary>Option B: Create a new project without Git upstream</summary>
    <p>
    Create a new project without Git upstream:

    ```console
    cd keptn-onboarding
    keptn create project simpleproject --shipyard=./shipyard.yaml
    ```
    </p>
    </details>

1. At this point, the project does not contain any deployable services yet. Therefore, we now have to onboard our **simplenode** service:

    ```
    keptn onboard service simplenode --project=simpleproject --chart=./simplenode
    ```
   
1. Now the service is onboarded and if you have set a Git upstream, you can view the configuration files that Keptn has generated in your Git repository. For each stage we have defined in our shipyard.yaml, there will be a branch that holds the configuration for the 
application running in that stage. Each change made to the configuration will be made through a git commit, which will make it easy to track every change that has been done to the configuration!

---

:arrow_forward: [Next Lab: Deploying the simplenode service](../02_Deploying_simplenode_service)

:arrow_up_small: [Back to overview](https://github.com/keptn-workshops/getting-started#overview)