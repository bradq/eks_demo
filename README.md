# Demo EKS Kubernetes Cluster

A demonstration Kubernetes deployment effected via Terraform.

### Prerequisites

In order to properly use this code repository, the following should be available locally:
* Administrative access to necessary Amazon Web Services provided by on of the standard [authentication provider chain members](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html).
* Modern Terraform (tested against latest 0.11.11 with AWS provider 1.54.0)
* A current installation of `kubectl`
* An altered service definition for `sample-webapp-prod` using a unique DNS name managed by Route53
* [`aws-iam-authenticator`]() installed locally (`go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator`)

Your AWS account should be populated with:
* An existing Route53 domain matching the one selected above.

### Use
Presuming the above requirements are fulfilled, execute "build.sh" at the root of the web directory will provision the cluster and deploy a working application to the public internet. Terraform configuration settings can be found in `terraform/variables.tf`

### Design Considerations
* The `build.sh` script is decidedly crude, and notably not idempotent. I'd generally expect more nuanced flow control from whatever service fronts this automation (Jenkins, CLI, etc)
* The pro forma Terraform for basic structure has been copied shamelessly from Terraform's [example code for EKS setups](https://learn.hashicorp.com/terraform/aws/eks-intro), though modifications have been made when warranted. Shortcomings have been copied as well; the network should use a NAT gateway rather than assigning public IP addresses and likely firewalled. 
* In a true production environment I'd expect the Terraform to look dramatically different: less inline literals and more discovery through variables and tags.
* Configuration for remote state is left commented out for your own ease of use. I'd consider it a healthy reminder that local state is almost always a mistake.
* I've deliberately sidestepped native Kubernetes configuration in the interest of time, instead leveraging EKS. As is generally true with AWS services, this is ideal for testing. Production design would depend on evaluation of need re: vendor lock-in, versioning needs, and staffing for ongoing maintenance.
* I end up using SSL via AWS's ACM; this is admittedly a convenience and applicability depends on use case. If compliance/security needs dictate end-to-end SSL throughout, the proper approach would be to deploy the application container to a pod with an SSL proxy sidecar. 
* Most of this work is considerably heavier commenting than I'd offer on a production project. Extensive commenting generally means one's following some unpleasantly novel trains of thought. 

### Efficacy
Currently the project requirements are fulfilled with bonuses in place but not yet effective. 
* The Terraform spins up a completely functional EKS cluster with standard VPC-based routing in a single region across AZs
* The worker nodes are in an autoscaling group and are capable of autoscaling, though only a simple instance-count scaling policy is in place. 
* The cluster assigns a "regular" user to the nodes themselves under the reserved `system` namespace. An `eks-admin` role is created in anticipation of being consumed by engineering and made available to Kubernetes as simply "admin". 
* The application deploys successfully, though pulling from public registries. 
* A cross-platform DNS registration pod is deployed and distributed as part of application deployment and the application's LoadBalancer configured to request public DNS. Currently not functional due to Kubernetes user rights. 
* SSL has not been implemented, and approach is rather dependent on use case. At the easiest, the `service.beta.kubernetes.io/aws-load-balancer-ssl-cert` annotation can be placed on the load balancer service pointing to an ACM ARN. If truly end-to-end encryption is required, a generic sidecar SSL termination proxy should be used. 

### Destruction
All resources are lost with the destruction of the Terraform-created environment. A simple `terraform destroy` from the `terraform/` directory will remove all traces of the cluster.