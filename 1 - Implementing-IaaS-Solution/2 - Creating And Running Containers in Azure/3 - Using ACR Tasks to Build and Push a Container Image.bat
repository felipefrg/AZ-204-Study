$ACR_NAME='psdemoacrfrg'

//Use ACR build to build our image in azure and then push that into ACR
az acr build --image "webappimage:v1-acr-task" --registry $ACR_NAME
az acr build --image "docker101tutorial:v1-acr-task" --registry $ACR_NAME

//Both images are in there now, the one we built locally and the one build with ACR tasks
az acr repository show-tags --name $ACR_NAME --repository webappimage --output table