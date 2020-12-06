#### How to build VM image with packer

  - Create 'packer-rg' resource group from Azure Portal.
  - Use 'build.sh' to start with new image build with packer. What does the script do?

    * Create Application service principal from Azure AD that produce attributes client_id, client_secret, tenant_id, appId, etc.
    * Application SP assume 'Owner' role. You can freely change 'ROLE' parameter in script when security is concerned.
    * Pass necessary SP parameters to packer prior to a build process.

```
./build.sh
```

  - After build succeeded, follows with cli to get image Id. This Id value will be useful in next part of terraform run.

```
az image list --resource-group packer-rg -o json | jq .'[]'.id
```

  - Delete image whenever need to replace an existing one.

```
az image delete -n Ubuntu_image_1804_lts --resource-group packer-rg
```

#### References

  1. [Packer guide](https://subramanisundaram.medium.com/packer-with-azure-build-automated-machine-images-4ccb104faf4f)
  2. [Packer user vars](https://www.packer.io/docs/templates/user-variables.html)
  3. [Packer shell provisioners](https://www.packer.io/docs/provisioners/shell.html)
  4. [Choose B-series burstable virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable)

