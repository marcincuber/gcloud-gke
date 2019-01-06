# Google Kubernetes Engine- Terraform

This repository is dedicated to work I conducted in Google Cloud environment. It uses Terraform to build resources such as Network, Kubernetes Cluster (private), roles, service accounts.

## Terraform templates and modules

In [terraform/](terraform/) you can find working examples for network setup with private/public subnetworks. Also, you can find firewall configurations which allow access only from public subnetwork to private one. 

For GKE configuration, we are using gcloud beta terraform provider which allows us to use the latest option which makes the cluster private. For this option to work we needed network to have VPC-native (alias IP) enabled. Access to API server is limited to my home IP. Please modify it in the `terraform/cluster.tf` with your desired selection. 

Kubernetes worker nodes are private therefore they can't route out. So solve that I used a managed service called `Cloud NAT` which is in beta in gcloud. Currently not supported by terraform. In order to ssh to worker nodes you have to tunnel through bastion host which is placed in public subnetwork.

## Docs

You can find scratch documentation in [docs/](docs/). I wrote them while working through various implementations. You will find helpful commands and links to external documents.

### Test
```
make all
```
### Terraform plan
```
make tf-plan
```
### Terraform apply
```
make tf-apply
```

## Disclaimer
_The SOFTWARE PACKAGE provided in this page is provided "as is", without any guarantee made as to its suitability or fitness for any particular use. It may contain bugs, so use of this tool is at your own risk. We take no responsibility for any damage of any sort that may unintentionally be caused through its use._

## Contacts

If you have any questions, drop an email to marcincuber@hotmail.com and leave stars! :)