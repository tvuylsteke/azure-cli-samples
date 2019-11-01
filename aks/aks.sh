#https://aksworkshop.io/
subscription="MSDN THOVUY P130b"
#select subscription
az account set --subscription "$subscription"

version=$(az aks get-versions -l westeurope --query 'orchestrators[-1].orchestratorVersion' -o tsv)
echo $version



#Resource Group
rg="aks-learning-friday"
az group create --name $rg --location westeurope

#WE VNET
vnet=aks-learn-vnet
subnet=aks
#create VNET
az network vnet create -g $rg -n $vnet --address-prefix 10.1.0.0/16 --subnet-name $subnet --subnet-prefix 10.1.0.0/21 -l westeurope

#create subnet
subnet=servers
az network vnet subnet create -g $rg -n $subnet --vnet-name $vnet --address-prefix 10.1.8.0/24

#get the subnet id.
az network vnet subnet list \
    --resource-group $rg \
    --vnet-name $vnet \
    --query [].id --output tsv

#or eassier:
export subnetid=$(az network vnet subnet show --resource-group $rg --name aks --vnet-name $vnet --query id -o tsv)

az aks create \
    --resource-group $rg \
    --name akslearn \
    --node-count 1 \
    --network-plugin azure \
    --vnet-subnet-id $subnetid \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.2.0.10 \
    --service-cidr 10.2.0.0/24 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --kubernetes-version $version \
    --location westeurope


#connect
az aks get-credentials --resource-group $rg --name akslearn
cat /home/thomas/.kube/config

#view current context
kubectl config view

#
# demo: KUARD

#apply something by just copy pasting
cat <<eof | kubectl apply -f -
copy paste
eof

#POD
apiVersion: v1
kind: Pod
metadata:
  name: kuard
  labels: 
    app: kuard
spec:
  containers:
  - image: gcr.io/kuar-demo/kuard-amd64:blue
    name: kuard
    ports:
    - containerPort: 8080
      name: http
      protocol: TCP

#SERVICE
apiVersion: v1
kind: Service
metadata:
  name: kuard-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: kuard

#

#get cluster service principal
#deploy app gw ingress: https://azure.github.io/application-gateway-kubernetes-ingress/setup/install-new/

az aks list



#

k describe ClusterRole cluster-admin

helm init --service-account tiller

k get pod --all-namespaces


#https://github.com/helm/charts/blob/master/stable/mongodb/values.yaml
helm install stable/mongodb --name orders-mongo --set mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
#helm install stable/mongodb --name orders-mongo -f values.yaml

#pod
k run nginx --image=nginx --restart Never -o yaml --dry-run
#deployment
k run nginx --image=nginx --restart Always -o yaml --dry-run

#apply something by just copy pasting
cat <<eof | kubectl apply -f -
copy paste
eof

#show stdout of a pod
k logs podname

#keep watching cmd until something changed
k get service -w

curl -d '{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}' -H "Content-Type: application/json" -X POST http://65.52.149.220/v1/order

k get events

kubectl create namespace ingress-basic

touch nginx-ingress.values.yaml

##
# Default values for nginx.
# This is a YAML-formatted file.
# Declare name/value pairs to be passed into your templates.

replicaCount: 6
restartPolicy: Never

# Evaluated by the post-install hook
sleepyTime: "10"

index: >-
  <h1>Hello</h1>
  <p>This is a test</p>

image:
  repository: nginx
  tag: alpine
  pullPolicy: IfNotPresent

service:
  annotations: {}
  clusterIP: ""
  externalIPs: []
  loadBalancerIP: ""
  loadBalancerSourceRanges: []
  type: ClusterIP
  port: 8888
  nodePort: ""

podAnnotations: {}

resources: {}

nodeSelector: {}
##

# Use Helm to deploy an NGINX ingress controller
helm install stable/nginx-ingress     --namespace ingress-basic -f nginx-ingress.values.yaml

#https://docs.microsoft.com/en-us/azure/aks/ingress-tls
#https://medium.com/@cashisclay/kubernetes-ingress-82aa960f658e

##
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: orderfrontend
  namespace: ingress-basic
  annotations:
    kubernetes.io/ingress.class: nginx    
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec: 
  rules:
  - host: aks.setspn.be.eu.org
    http:
      paths:
      - backend:
          serviceName: frontend
          servicePort: 80
        path: /(.*)
      - backend:
          serviceName: captureorder
          servicePort: 80
        path: /api(/|$)(.*)

        ##

k port-forward pods/frontend-5ff4d56cdc-68gmm :8080 &

az container create -g aks-at-reading -n loadtest --image azch/loadtest --restart-policy Never -e SERVICE_IP=65.52.149.220 
az container logs -g aks-at-reading -n loadtest
az container delete -g aks-at-reading -n loadtest

#select only pods with your label
kubectl get pods -l  app=captureorder

#KUARD pod