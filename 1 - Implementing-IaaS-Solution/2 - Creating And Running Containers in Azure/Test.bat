az login
az account set --subscription "00655dc1-6754-4c6f-9aaf-611d53dede73"

@REM //Create Resource Group
az group create --name "psdemo-rg" --location "brazilsouth"

@REM //Create Container
$ACR_NAME='psdemoacrfrg'
az acr create --resource-group psdemo-rg --name $ACR_NAME --sku Standard

@REM //Login into container registry
Az acr login --name $ACR_NAME

$ACR_LOGINSERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
echo $ACR_LOGINSERVER

@REM //Tag the container image using the login server name. This doesn`t push it to ACR, that's
@REM //the next step
@REM //#[loginUrl]/[repository:][tag]
docker tag docker101tutorial $ACR_LOGINSERVER/docker101tutorial:v1
docker image ls $ACR_LOGINSERVER/docker101tutorial:v1
docker image ls

@REM // Push image to Azure Container Registry
docker push $ACR_LOGINSERVER/docker101tutorial

@REM //Get a listing of the repositories and images/tags in our Azure Container Registry
az acr repository list --name $ACR_NAME --output table
az acr repository show-tags --name $ACR_NAME --repository webappimage --output table

//Use ACR build to build our image in azure and then push that into ACR
az acr build --image "webappimage:v1-acr-task" --registry $ACR_NAME
az acr build --image "docker101tutorial:v1-acr-task" --registry $ACR_NAME

//Both images are in there now, the one we built locally and the one build with ACR tasks
az acr repository show-tags --name $ACR_NAME --repository webappimage --output table


az group delete --name psdemo-rg