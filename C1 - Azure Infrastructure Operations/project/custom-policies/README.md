#### Example: Inherit a tag from the resource group if missing

  * tag policy example ref: https://github.com/Azure/azure-policy/tree/master/samples/Tags/inherit-resourcegroup-tag-if-missing
  * definition ref: https://docs.microsoft.com/en-au/azure/governance/policy/concepts/definition-structure
  * policy creation ref: https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage
  * policy programtical creation ref: https://docs.microsoft.com/en-au/azure/governance/policy/how-to/programmatically-create
  * service principal ref:  https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli
  * terraform SP client secret ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret

  * To create a custom policy using the azure portal

```
- In azure portal, search for Policy and open it.
- Select Definitions under Authoring in the left side of the Azure Policy page.
- Select + Policy definition at the top of the page. This button opens to the Policy definition page.
- Then you need to create your custom tagging policy. You can see other available tag policies from the list to get an idea how to create the policy.
- After you have created the policy, you need to assign the custom policy to your azure subscription-

- Select Assignments on the left side of the Azure Policy page. An assignment is a policy that has been assigned to take place within a specific scope.
- Select Assign Policy from the top of the Policy - Assignments page.
- On the Assign Policy page and Basics tab, select the Scope by selecting the ellipsis and selecting subscription.
- Select the Policy definition ellipsis to open the list of available definitions.
- Select your custom policy.
- After you have assigned the policy, you can confirm this through the CLI by running the command to check assigned policies.
```
  
  * Use script to install policy

```
./install.sh
```

  * Show assignment 

```
az policy assignment list -o table
```
