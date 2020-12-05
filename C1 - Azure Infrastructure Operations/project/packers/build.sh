#!/usr/bin/env zsh

# set specify the Subscription to use:
SUBSCRIPTION_ID=$(az account list | jq -r .'[]'.id)
az account set --subscription="${SUBSCRIPTION_ID}"

# Set APP_ID
APP_ID="SP-Role-VM-Operator"
# See pre-defined role
# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#virtual-machine-contributor
ROLE="Owner"

# Test if APP_ID exists?
SP=$(az ad sp show --id "http://${APP_ID}" 2>/dev/null | jq -r .'servicePrincipalNames[0]?')

# create the Service Principal which will have permissions to manage resources in the specified Subscription
# examples:
# --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
CLIENT_SECRET=""
if [ -z "${SP}" ]; then
	CLIENT_SECRET=$(az ad sp create-for-rbac --name $APP_ID \
   		--role=$ROLE \
   		--scopes="/subscriptions/${SUBSCRIPTION_ID}" \
   		--query password --output tsv) 
else
	CLIENT_SECRET=$(az ad sp credential reset --name $APP_ID --query password --output tsv)
fi

CLIENT_ID=$(az ad sp show --id "http://${APP_ID}" | jq -r .'servicePrincipalNames[1]')
TENANT_ID=$(az ad sp show --id "http://${APP_ID}" | jq -r .'appOwnerTenantId')

echo "app_id=${SP}"
echo "client_id=${CLIENT_ID}"
echo "client_secret=${CLIENT_SECRET}"
echo "tenant_id=${TENANT_ID}"
echo "subscription_id=${SUBSCRIPTION_ID}"
echo "role=${ROLE}"

# Build with packer
packer build -var "subscription_id=${SUBSCRIPTION_ID}" \
	-var "client_id=${CLIENT_ID}" \
	-var "client_secret=${CLIENT_SECRET}" \
        -var "tenant_id=${TENANT_ID}" \
	server.json

# Delete Service Principal
az role assignment delete --assignee "http://${APP_ID}" --role $ROLE
az ad sp delete --id "http://${APP_ID}"
