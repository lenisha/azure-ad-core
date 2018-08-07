#create vm in Subnet

az vm create \
    --resource-group testdocker \
    --name vmSec1 \
    --location eastus \
    --admin-username azureuser \
    --admin-password "" \
	--subnet /subscriptions/xxxx/resourceGroups/testdocker/providers/Microsoft.Network/virtualNetworks/testdocker-vnet/subnets/default \
	--public-ip-address "" \
	--size Standard_D4s_v3 \
	--image RHEL
	