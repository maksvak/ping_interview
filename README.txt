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
        

EKS: 