#Demo 1 - Create a container in Azure Container Instance
#Login
az login
az account set --subscription "00655dc1-6754-4c6f-9aaf-611d53dede73"

az group create --name psdemo-rg --location centralus

az group list

#Demo 0 - Deploy a container from a public registry
az container create --resource-group psdemo-rg --name psdemo-hello-world-cli --dns-name-label psdemofrg-hello-world-cli --image mcr.microsoft.com/azuredocs/aci-helloworld --port 80

#Show the container info
az container show --resource-group 'psdemo-rg' --name 'psdemo-hello-world-cli'

#Retrieve the URL, the format is [name].[region].azurecontainer.io
$URL=$(az container show --resource-group 'psdemo-rg' --name 'psdemofrg-hello-world-cli' --query ipAddress.fqnd | tr -d '"')
echo "http://$URL"
    

#Demo 1 - Deploy a container from Azure Container Registry with authentication
#Step 0 - Set some enviroment variables and create Resource group for our Demo
$ACR_NAME='psdemoacrfrg'
echo $ACR_NAME

#Step 1 - Obtain the full registry ID and login server which will well use in the security 
#and create sections of the demo
$ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
$ACR_LOGINSERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

echo "ACR ID: $ACR_REGISTRY_ID"
echo "ACR Login Server: $ACR_LOGINSERVER"

#Step 2 - Create a serve principal and get the password and ID, this will allow Azure Container Instance to Pull
$SP_NAME="acr-service-principal"
$SP_PASSWD=$(az ad sp create-for-rbac --name http://$ACR_NAME-pull --scopes $ACR_REGISTRY_ID --role acrpull --query password --output tsv)

$SP_APPID=$(az ad sp show --id http://$ACR_NAME-pull --query appId --outpu tsv)
echo "Service principal ID: $SP_APPID"
echo "Service principal Password: $SP_PASSWD"

#Step3 - Create the container in ACI, this will pull our image named
#$ACR_LOGINSERVER is psdemoacrfrg.azurecontainer.io. This should match *your* login server name
az container create  --resource-group psdemo-rg --name psdemo-webapp-cli --dns-name-label psdemofrg-webapp-cli --ports 80 --image $ACR_LOGINSERVER/webappimage:v1 --registry-login-server $ACR_LOGINSERVER --registry-username $SP_APPID --registry-password $SP_PASSWD

#Step 4 - Confirm the container is running and test access to the web application, looke in instanceView.state
az container show --resource-group psdemo-rg --name psdemo-webapp-cli

#Get the URL of the container running in ACI
#this is our hello world app we build in the previous demo
$URL=$(az container show --resource-group 'psdemo-rg' --name 'psdemofrg-hello-world-cli' --query ipAddress.fqnd | tr -d '"')
echo $URL
$FDQN="psdemofrg-webapp-cli.centralus.azurecontainer.io"
curl $FDQN

#Step 5 - Pull the logs from the container
az container logs --resource-group psdemo-rg --name psdemofrg-webapp-cli

#Step 6 - Delete the running container
az container delete --resource-group psdemo-rg --name psdemofrg-webapp-cli --yes

#Step
az group delete --name psdemo-rg --yes
docker image rm psdemoacrfrg.azurecr.io/webappimage:v1
docker image rm webappimage:v1