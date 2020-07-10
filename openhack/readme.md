# Challenge 1

# troubleshooting commands

docker ps
docker inspect sqlthovuy

# Build container

docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" -f ../../dockerfiles/poi -t "registryrxt3043.azurecr.io/team1/poi:1.0" .

# run SQL
# https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver15&pivots=cs1-bash#create-and-query-data

docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Admin@Azure01" \
   -p 1433:1433 --name sqlthovuy \
   -d mcr.microsoft.com/mssql/server:2019-CU5-ubuntu-18.04

SQL_PASSWORD="Admin@Azure01"
SQL_SERVER="172.17.0.2"

sudo docker exec -it sqlthovuy "bash"
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Admin@Azure01"

CREATE DATABASE mydrivingDB
GO

# data load
docker run -e SQLFQDN=$SQL_SERVER -e SQLUSER=SA -e SQLPASS="Admin@Azure01" -e SQLDB=mydrivingDB openhack/data-load:v1
  
# POI container
docker run -d -p 8080:80 --name poi -e "SQL_PASSWORD=$SQL_PASSWORD" -e "SQL_SERVER=$SQL_SERVER" -e "ASPNETCORE_ENVIRONMENT=Local" -e "SQL_USER=SA" tripinsights/poi:1.0

docker ps
docker inspect poi
docker logs poi

ACR_NAME=registryrxt3043
az acr login --name $ACR_NAME

docker image list

docker push registryrxt3043.azurecr.io/team1/poi:1.0

# Create an AKS cluster
# https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough

az aks get-credentials -g aks -n aks-team1


kubectl run poi --image=team1/user-jave:1.0 -o yaml --dry-run > user.yaml

k describe pod trips-68844d7f4c-l2qqm

k port-forward pods/trips-bf485975f-k7bqm 8888:80

k apply -f user.yaml

k exec -it podname printenv
k exec -it podname nslookup

k get all -A
k get all -n namespace

k top node