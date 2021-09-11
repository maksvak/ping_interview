# Ping Identity: Mt. Fuji Product

## Conceptual walkthrough

We are creating a basic web server running on a Kubernetes cluster. This web server will go into an S3 bucket and return an index.html when called. 
Further the service can scale based on use. This use is tied directly to the CPU status of the pod. 

This will create:
  - Namespace: fuji
  - Deployment: httpd-appf
  - Horizontal Pod Autoscaler: httpd-app-hpa
  - Service: httpd-service

## Environment
~/interviews
--deploy.yaml
--index.html
--route.json
-docs
--readme.md
-tests
--test.sh

## Deployment

Apply the deploy.yaml

    kubectl create -f deploy.yaml --save-config

To connect to the AWS ELB we need a record in Route53.

Run to get the elb address

    kubectl -n fuji get svc httpd-service

    example:
      a6e4e7c7e58384487aaf784a5f1b9412-2069570988.us-west-2.elb.amazonaws.com
  
  Edit the route.json and replace the dnsname variable with the address

Run to implement the record change: 

    aws route53 change-resource-record-sets --hosted-zone-id Z18D5FSROUN65G --change-batch file://route.json

    hosted-zone-id can be found here: https://docs.aws.amazon.com/general/latest/gr/elb.html
    Zone is us-west-2b



## Cleanup 
Delete the deployment 
kubectl delete -f deploy.yaml

## Tests

To test if everything has been spun up, navigate to the /interviews/tests/ directory and run the file "tests.sh"
I also had to chmod +x tests.sh to get it to run. 

## Acceptance Criteria 

  All Resources should be deployed to a namespace called fuji
    All resources are deployed under a namespace fuji with the exception of the logger.

  Create a deployment of an application running an http deamon
    deploy.yaml creates pods running apache tp use as a webhost. It listens on port 80. 
  
  The deployment should automatically scale under load
    AWS provides a kubernetes metrics server. I chose to use that for simplicity. It deploys to namespace kube-system
      https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
    I then set arbitrary resource limits on the pods 'and the HPA simply uses them to know when to scale. 

  The HTTPD must also serve an index.html file
    I modified the file in the s3 bucket to have the right information in it, then reuploaded it. 
    To get the file into the pods I used a command argument during creation to run:
      1. apt-get update 
      2. apt-get install awscli -y (this installs aws command line too)
      3. aws s3 cp s3://beluga-fuji/index.html /usr/local/apache2/htdocs/index.html; cat /usr/local/apache2/htdocs/index.html (this copies the file from s3 to the apache server into the right directory)

        Note: I think there is a way to avoid having to install this stuff and using a configMap to connect the s3 bucket, or the index file to the deployment. However I 
        was unable to get this to work. This installation process is resource intensive - I was not able to get it to run on minikube on my personal machine. 
  
  Expose the deployment as an external service and provide an ingress for it. 
    By mapping my load balancer service to the AWS ELB, this would theoretically redirect traffic to my cluster and a request on port 80
    would return the index.html. Unfortunatly I was unable to fully test this as I lost permissions for cluster creation, as well as making 
    route53 address changes. 

  Add some end to end testing for your application 
    Wrote some basic test in bash in order to test out the current status of the cluster and deployment. Limited test success due to resource issues.
    
  Add some documentation to the implementation
    This is it. 


## Additional Notes: 

This was a great learning experiance. A week ago I had almost no seat time with kubernetes and EKS, but after spending a few days working with it, 
I am definitly excited for the oppertunities it provides. This project was definitly a struggle to get up and going, as well as the permissions issues I 
had outside of my control, but it was a lot of fun, and I continued doing some of the dev work on minikube on my person machine. 

I appreciate the opportunity to interview with Ping. 

M