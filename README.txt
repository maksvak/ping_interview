README
Kubernetes:

    Parts:
        configMap: the brains of the deployment 
        deployments: this is how we interact with K8s, lowest level of control
        service: port mapping both internal and external connections
        pods: lowest building block
        nodes: master and worker nodes. Master controls opperations, workers do the work
        namespace: way to group projects 
        secrets: used to store credentials
        persistantvolume: storage mapping (namespace not required) 
        persistantvolumeclaim: connecting storage from inside app - claims a volume (inside namespace)
        storage class: provisions PV dynamically and it gets claimed
        Ingress:  allows service access from outside. 
    
    StatefulSet
        used for stateful applications
        stateful is database - stores data to keep track of something
        Stateless is deployed uysing deployment 
        stateful is deployed using StatefulSet
        maintaines ID for pod since they are not interchangeable        

    People:
        Admin: sets up cluster and manages resources (devops engineer)
        User: deploys apps inside a cluster 

    Storage: 
        Persistant Volume - resource used to store data
        created by a YAML file
        Needs actual physical storage. This is an interface

    Services: 
        Each pod gets an internal IP address 
        New one each time it gets created
        ClusterIP
            default type
            maps ip and port for each nodes
            Targetport: this is the port on the node. 
            get endpoints - so it keeps track of the pods using a service
        MultiPort service   
            name ports 
            this is if you need a log scanner or something on second port
        Headless Service 
            communicate with a specific pod (normal service is random based on availability)
            useful for stateful applications because we need to be able to reach a specific unit
            data sync between databases
            along side clusterIP service
        3 service type attributes
            ClusterIP - default  
            Loadbalancer - accessible externally through a cloud provider load balancer
                noteport and clusterIP is created automatically - so the cloud platform can route 
            nodePort - creates a service that is on static port on each worker node; instead of ingress, marks down to port 
                30000-32767 range of value
                automatically create clusterIP 
                not efficient, not secure 

YAML:

    Serialized langauge - standard format for transfer 
    indent specific 
    easiest to read 
    key value pairs 
    # comments 


EKS: 