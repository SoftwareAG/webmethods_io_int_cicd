# wmio_project_d
 This article shows how to design and setup an automated CI/CD process and framework for Hybrid integration setup with 
 webMethods.io using the inbuilt APIs (or CLI). Here we have used Azure DevOps as our orchestration platform, 
 GitHub as repository platform and Postman/Newman as test framework. 

# Use-case
When organizations start using webMethods.io Integration along with on-premise integration for business use-cases, the need for having a continuous integration and delivery process becomes very important. These processes will enable the business to have a "Faster release rate", "More Test reliability" & "Faster to Market".
This use-case will highlight a solution utilizing below 
1) scaffodls/manifest.yaml file which mentions repository URL and project type ( on premise/ API/ WMIO etc.)
2) for WebMethods.io (cloud) - webMethods.io import & export APIs (or CLI) and Azure Devops to extract and store the code assets in repository (GitHub).
3) for Webmethos IS (onpremise) - webMethods IS local service development and Azure DevOps to extract and store the code assets in repository (GitHub).
By integrating repository workflows and azure pipelines, this process will automate the promotion of assets to different stages/environment as per the organizations promotion workflow. This will also showcase how to automate the test framework for respective stages/environments.

![](./images/markdown/OnPrem_App_WxConfig.png)  ![](./images/markdown/wm_io.png) ![](./images/markdown/hybrid_devops_overview.png)

# Assumptions / Scope / Prerequisite
1. 4 Environments: Play/build, Dev, QA & Prod. 
2. Azure DevOps as Orchestration Platform
3. GitHub: as the code repository
4. GitHub Enterprise: For Pipelines/Scripts
5. Postman/Newman as test framework
6. Microsoft’s self-hosted agent on the build server where ABE and webMethods deployer are installed for IS packages
7. Scaffolds/manifest.yaml file updated for assets


# Git Workflow
We will assume that the organization is following the below GIT Workflows.

![](./images/markdown/SingleFeature.png)    ![](./images/markdown/MultiFeature.png)


# Concept

1. Scaffolds/manifest.yaml file is created for each project and it looks like this.

![](./images/markdown/scaffolds.png)

2. Based on the type, the pipelines are executed.

3. for wm.io , follow the same steps ( https://github.softwareag.com/PS/webmethods_io_int_cicd)

4. for integration server (on premise) , the below steps are done

i) Initialize pipeline creates feature branch ( if the repository is new then initialize pipeline creates repository and branches)
ii) Developer checks out the feature branch , develops the code and commits it.
iii) synchronizeToDev pipeline is initiated to deploy the code in dev environment.


# Git Workflow
We will assume that the organization is following the below GIT Workflows.

![](./images/markdown/SingleFeature.png)    ![](./images/markdown/MultiFeature.png)

# Steps
1. **Initialize**
   1. Developer starts by executing *Initialize Pipeline* (Automation)
   2. This checks if the request is for an existing repository or a new one
   3. If new, automation will 
      1. Initialize a repository
      2. Create standardized branches, including requested Feature Branch
   4. If existing, automation will
      1. Clone the Prod branch to Feature branch

<br> 
<br> 
<br> 


2. **Develop & Commit**
   1. Developer starts developing
   2. After completion they will execute synchronizeToDev Pipeline (Automation)