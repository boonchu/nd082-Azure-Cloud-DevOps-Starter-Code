#### Deny when miss to inherit a tag in the resources.

  * When you are not familar how to put policy in place programmatically, please uses 'Azure Portal' to create a custom policy.

```
- In azure portal, search for Policy and open it.
- Select Definitions under Authoring in the left side of the Azure Policy page.
- Select + Policy definition at the top of the page. This button opens to the Policy definition page.
- Then you need to create your custom tagging policy. You can see other available tag policies from the list to get an idea how to create the policy.
- After you have created the policy, you need to assign the custom policy to your azure subscription.
- Select Assignments on the left side of the Azure Policy page. An assignment is a policy that has been assigned to take place within a specific scope.
- Select Assign Policy from the top of the Policy - Assignments page.
- On the Assign Policy page and Basics tab, select the Scope by selecting the ellipsis and selecting subscription.
- Select the Policy definition ellipsis to open the list of available definitions.
- Select your custom policy.
- After you have assigned the policy, you can confirm this through the CLI by running the command to check assigned policies.
```
  
  * When choose to automate the policy deployment, use script to install policy.

```
- Two files were prepared in repository. 
  * tagging-policy.rules.json
  * tagging-policy.parameters.json 
- Push deployment with subscription scope.
- Afer change, policy deny any newly resource creation/requests tag if tag name 'role' is not implemented in resource.
```

  * Deploy policy with script.

```
./install.sh
```

#### Outputs

```
az policy assignment list -o table
```

  * See output 'az policy assignment list' from file 'tagging-policy.png'.

#### References

  1. [Tag policy example](https://github.com/Azure/azure-policy/tree/master/samples/Tags/inherit-resourcegroup-tag-if-missing)
  2. [Policy definition](https://docs.microsoft.com/en-au/azure/governance/policy/concepts/definition-structure)
  3. [Policy creation](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage)
  4. [Policy programtical creation ref](https://docs.microsoft.com/en-au/azure/governance/policy/how-to/programmatically-create)
  5. [Service Principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
  6. [Terraform Service Principal client secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
