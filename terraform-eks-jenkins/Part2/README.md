# Jenkins pipeline to trigger and deploy EKS cluster with terraform module calls

Deploy AWS EKS via a Jenkins job using terraform. I here by to deploy EKS on AWS environments, specifying some settings via pipeline parameters.
![image](https://user-images.githubusercontent.com/35074202/111352925-08b84b00-8685-11eb-8913-4765d90d9986.png)
  Used draw.io(https://app.diagrams.net/) tool to define this diagram
### Jenkins pipeline

Jenkins needs the following linux commands, which can either be installed via the Linux package manager or in the case of terraform, downloaded:
```
terraform (0.12.x)
jq
kubectl
```
The pipeline uses a terraform workspace for each cluster name, so you should be safe deploying multiple clusters via the same Jenkins job. Obviously state is maintained in the Jenkins job workspace.

### Store terraform state in an s3 bucket
This the recommended method, as keeping the stack in the workspace of the Jenkins job is a bad idea! See terraform docs for this. You can probably add a Jenkins parameter for the bucket name, and get the Jenkins job to construct the config for the state before running terraform.

### Implement locking for terraform state using dynamodb
Similar to state, this ensure multiple runs of terraform cannot happen. See terraform docs for this. we can get the dynamodb table name as a Jenkins parameter.

```
I am using terraform to create our infrastructure code and helm charts to deploy kubernetes resources. Have a separate repo to create the EKS cluster. Output the eks endpoints from the repo. Every service that need to be deployed to EKS use those terraform output variables and then create the helm chart via terraform.
