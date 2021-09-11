
#!/bin/bash
set -e

ENDPOINT="http://httpd-maksimvakulenko.ping-fuji.com"

test_resource_exists () {
        RESOURCE=$1
        ERR_MSG=$2
        if [[ -z "$RESOURCE" ]]; then
                echo "$ERR_MSG"
                exit 1
        fi
}

test_equality () {
        ACTUAL=$1
        TARGET=$2
        ERR_MSG=$3
        if [[ "$ACTUAL" != "$TARGET" ]]; then
                echo "$ERR_MSG"
                exit 1
        fi
}

# test if fuji namespace exists
test_namespace () {
        echo "Test if fuji namespace exists"
        NAMESPACE=$(kubectl get namespace | grep fuji)
        test_resource_exists "$NAMESPACE" "Namespace 'fuji' missing"
}

# test if deployment httpd-app exists
test_httpd_deployment () {
        echo "Test httpd-app deployment exists"
        DEPLOYMENT=$(kubectl get deployment -o name -n fuji | grep httpd-app)
        test_resource_exists "$DEPLOYMENT" "Deployment httpd-app is missing"

        echo "Test httpd:latest image is used in httpd-app deployemnt"
        CONFIGS=$(kubectl -n fuji get deployment httpd-app -o=jsonpath='{$.spec}')
        IMAGE=$(echo "$CONFIGS" | jq -r '.template.spec.containers[0].image')
        test_equality "$IMAGE" "httpd:latest" "The httpd-app deployment is not using httpd:latest"

        echo "Test open port on pods"
        PORT=$(echo "$CONFIGS" | jq ".template.spec.containers[0].ports[0].containerPort")
        test_equality "$PORT" "80" "Port 80 is not open on the httpd-app pods"

}

test_autoscaling_exist () {
        echo "Test autoscaling exists"
        HPA=$(kubectl get hpa -n fuji -o name | grep horizontalpodautoscaler.autoscaling/httpd-app )
        test_resource_exists "$HPA" "HPA httpd-app-service does not exist"
}

test_autoscaling_config () {
        CONFIG=$(kubectl -n fuji get hpa httpd-app-hpa -o=jsonpath='{$.spec}')
        echo "Test to ensure hpa has max replicas of 4"
        MAX_REPLICAS=$(echo "$CONFIG" | jq ".maxReplicas")
        test_equality "$MAX_REPLICAS" "4" "Max Replica not set to 4"

        echo "Test to ensure hpa has min replicas of 2"
        MIN_REPLICAS=$(echo "$CONFIG" | jq ".minReplicas")
        test_equality "$MIN_REPLICAS" "2" "Min Replica not set to 2"
}

test_endpoint (){
        response=$(curl -s -w "%{http_code}" $ENDPOINT)
        http_code=$(tail -n1 <<< "$response")  # get the last line
        content=$(sed '$ d' <<< "$response")   # get all but the last line which contains the status code
}


test_namespace
test_httpd_deployment
test_autoscaling_exist
test_autoscaling_config
test_endpoint
