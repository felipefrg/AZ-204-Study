Demo 1:
#Realiza o login
az login 
#Define qual assinatura usar
az account set --subscription 00655dc1-6754-4c6f-9aaf-611d53dede73 
#Lista os resources groups existentes
az group list --output table 
#Cria um novo ResourceGroup
az group create --name "psdemo-rg" --location "centralus"
#Cria uma vm com windows server
az vm create --resource-group "psdemo-rg" --name "psdemo-win-cli" --image "win2019datacenter" -admin-username "demoadmin" --admin-password "password123$%^&*"
#Abre a porta 3389 do RDP (Remote Desktop)
Az vm open-port --resource-group "psdemo-rg" --name "psdemo-win-cli" --port "3389"
#Lista os ips externo e interno da vm
Az vm list-ip-addresses --resource-group --name "psdemo-win-cli" --output table
