#!/usr/bin/env zsh

# set specify the Subscription to use:
SUBSCRIPTION_ID=$(az account list | jq -r .'[]'.id)
az account set --subscription="${SUBSCRIPTION_ID}"

az policy definition create --name 'tagging-policy-rules' \
   --display-name 'Deny when 'role' tag is missing from Resources' \
   --description 'Deny to create resources when the specified tag tagName is missing' \
   --rules tagging-policy.rules.json \
   --params tagging-policy.parameters.json \
   --mode Indexed

az policy assignment create --name 'tagging-policy' \
   --scope "/subscriptions/${SUBSCRIPTION_ID}" \
   --policy "tagging-policy-rules" \
   --params "{'tagName':{'value': 'role'}}"
