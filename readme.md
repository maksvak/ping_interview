# Ping Identity: Mt. Fuji Product

## Conceptual walkthrough

We are creating a basic web server running on a Kubernetes cluster. This web server will go into an S3 bucket and return an index.html when called. 
Further the service can scale based on use. This use is tied directly to the CPU status of the pod. 



## Steps to recreate environment

Located in the /interviews directory is a file called "deploy.yaml"
Begin by using kubectl to apply that file.

kubectl create -f deploy.yaml --save-config
kubectl delete -f deploy.yaml

 kubectl exec -it -n fuji httpd-app-58977c776d-5pl7h -- /bin/bash

 kubectl create configmap html-configmap --from-file=s3://beluga-fuji/index.html -o yaml --dry-run


This will create five resources:
  - Namespace: fuji
  - Deployment: httpd-appf
  - Horizontal Pod Autoscaler: httpd-app-hpa
  - Configmap: html-configmap
  - Service: httpd-service

Because we are only working with a single service, I opted to create the httpd-service Service as a LoadBalancer, which since we
  are using AWS it allowed me to create an ELB that routed to the httpd-app pods.

We now need to route traffic to the AWS load balancer via the http://httpd-maksimvakulenko.ping-fuji.com endpoint. To do this we need
  to create a record in Route53.

The file /interviews/docs/create_record.json is prepopulated to create a new record in Route53. The only thing one would need to
  do is update the $.Changes[0].ResourceRecordSet.AliasTarget.DNSName variable to match the load balancer's external ip that is attached
  to the httpd-service.
You can get this record by running:

kubectl -n fuji get svc httpd-service


Copy the EXTERNAL-IP and insert into the create_record.json file as previously mentioned.

Once that has been done, run the command:
aws route53 change-resource-record-sets --hosted-zone-id Z18D5FSROUN65G --change-batch file://route.json




aws route53 list-hosted-zones-by-name | jq --arg name "ping-fuji.com." -r '.HostedZones | .[] | select(.Name=="\($name)") | .Id'

aws route53 list-resource-record-sets --hosted-zone-id "/hostedzone/Z18D5FSROUN65G"




This will create a record in Route53 so that the enpoint http://httpd-maksimvakulenko.ping-fuji.com can be routed to our httpd-app.

To test if everything has been spun up, navigate to the /interviews/tests/ directory and run the file "tests.sh"
cd /interviews/tests
./tests.sh

It should test whether all resources have been spun up and check that the endpoint is reachable with our html file.

## Design
Requirement: All resources should be deployed to a namespace called "fuji"
  As required all stated resources have been deployed to the "fuji" namespace.

Requirement: Create a deployment of an application running an HTTP daemon
  As required, a Deployment was created using the httpd:latest image. In actual deployments I would prefer to use a specific tag
    instead of "latest" as that would specify which version of the image to be used and would prevent issues with pods rolling
    and accidentally updating in the future.

Requirement: The deployment should automatically scale under load
  To get this one up and running a separate service needed to be deployed into the cluster as it doesn't come by default in EKS
  To do so I installed the metrics server using instructions from
  https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

  The documentation on that page instructed to run this for the cluster.
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

  This was not deployed in the "fuji" namespace, however, I hope this is an exception as it was something needed in the cluster.

  To begin collecting metrics from the pods, however, I needed to add resource limits in the deployment so that the Horizontal Pod Autoscaler
    knew what to look for when it was checking for if 60% of resources have been used.

Requirement: The HTTP daemon must also serve an index.html file found on "beluga-fuji"
