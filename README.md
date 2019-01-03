# Demo EKS Kubernetes Cluster

A demonstration Kubernetes deployment effected via Terraform.

### Prerequisites

In order to properly use this code repository, the following should be available locally:
* Administrative access to Amazon Web Services provided by on of the standard [authentication provider chain](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html).
* 2 provisioned IAM user accounts for administrative and test access
* Modern Terraform (tested against latest 0.11.11 with AWS provider 1.54.0)
* An unconfigured installation of `kubectl`
* A populated `terraform.tfvars` file. Use the `terraform.tfvars.sample` file as a basis. 
* [`aws-iam-authenticator`]() installed locally (`go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator`)

### Use
Presuming the above requirements are fulfilled, execute "build.sh" at the root of the web directory. 

### Design Considerations
* The execution script is decidedly crude, and notably not idempotent. I'd generally expect more nuanced flow control from whatever service fronts this automation (Jenkins, CLI, etc)
* To great extent, the pro forma Terraform has been lifted directly from Terraform's [example code for EKS setups](https://learn.hashicorp.com/terraform/aws/eks-intro), though substantive modifications have been made where warranted. 
* This approach is tailored to the problem presented. In a true production environment I'd expect to use considerably less proscriptive Terraform with less inline literals and more discovery through variables and tags.
* Likewise, this cluster _supports_ autoscaling, though there isn't a resource-based policy to 
* Configuration for remote state is left commented out. This is included as near-mandatory best practice to provide locking and shared state, but I'm avoiding external configuration requirements for the demo. 
* I've deliberately sidestepped native Kubernetes configuration in the interest of time, instead leveraging EKS. As is generally true with AWS services, this is ideal for testing. Production design would depend on evaluation of need re: vendor lock-in, versioning needs, and staffing for ongoing maintenance.
* You'd certainly not want to use direct user ARN bindings in most contexts, though it's most convenient here. AssumeRole would be the proper path in a group setting. 
* I end up using SSL via AWS's ACM; this is admittedly a convenience and applicability depends on use case. If compliance/security needs dictate end-to-end SSL throughout, the proper approach would be to deploy the application container to a pod with an SSL proxy sidecar. 
* Most of this work is considerably heavier commenting than I'd offer on a production project. 


### TODO: 
* Wait for full cluster before starting app
* Clean up dependency tree. 
* Create ECR, copy to ECR from source? 
* Double check, populate sample tfvars
* Complete build script
* Create users
* Remove public IPs from workers. 