# Scratch notes

## Authentication

Authenticate using service account' secret (json format)
```
gcloud auth activate-service-account [ACCOUNT] --key-file=KEY_FILE [--password-file=PASSWORD_FILE
```

## Credentials kubeconfig

Get kubectl credentials for the GKE cluster
```
gcloud container clusters get-credentials NAME [--internal-ip] [--region=REGION     | --zone=ZONE, -z ZONE] [GCLOUD_WIDE_FLAG …]
```

Examples:

### private cluster
```
gcloud container clusters get-credentials k8s-test --zone europe-west2-a --project ${project_name}
```

## NAT configuration of private worker nodes

I used a managed service called `Cloud NAT` which is in beta in gcloud. Currently not supported by terraform. Issue to follow -> https://github.com/terraform-providers/terraform-provider-google/issues/2249

Configuration details (create manually for now):
```
Cloud Router
    Region: europe-west2
    VPC network: priv-pub-subs-test-network
    Cloud Router: private-nat-router
NAT mapping
    High availability: Yes
    Source subnets & IP ranges: All subnets' primary and secondary IP ranges    
    NAT IP addresses: 35.234.147.169  35.230.151.57
Advanced configurations
    Minimum ports per VM instance: 64
    Timeout for protocol connections
        UDP: 30 seconds
        TCP established: 1200 seconds
        TCP transitory: 30 seconds
        ICMP: 30 seconds
```

Currently it routes `All subnets' primary and secondary IP ranges   
` through NAT Cloud. It has two custom(manual) allocated IPs.

You can test your NAT by simply running the following:
```
kubectl run example -i -t --rm --restart=Never --image centos:7 -- curl -s whatismyip.akamai.com
```

## Notes

List compute instances:
```gcloud compute instances list```

How can I access through ssh to the machine running the Kubernetes Engine?
```gcloud compute ssh NODE-NAME --zone ZONE```
Note: With this you access to the node. You can't access the master node, as it is Google managed.

How can I check a public IP of the machines running the Kubernetes engine?
```kubectl get no -o wide```

To know master node IP address:
```kubectl cluster-info | grep master```

List networks:
```gcloud compute networks list```

List subnets(subnetworks):
```gcloud compute networks subnets list --network priv-pub-subs-test-network```

Export project ID:
```export PROJECT_ID="$(gcloud config get-value project -q)"```

Deploy sample app:
https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app

NAT GATEWAY docs:
https://cloud.google.com/solutions/using-a-nat-gateway-with-kubernetes-engine

NAT GATEWAY HA review:
https://github.com/GoogleCloudPlatform/terraform-google-nat-gateway

Private GCLOUD clusters:
https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters?hl=en_GB&_ga=2.27065661.-1834281789.1540654994

RBAC docs:
https://github.com/GoogleCloudPlatform/gke-rbac-demo

Istio: 
https://cloud.google.com/kubernetes-engine/docs/tutorials/installing-istio

