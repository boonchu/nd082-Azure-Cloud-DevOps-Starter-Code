#### How to build VM image with packer

  - packer guide ref: https://subramanisundaram.medium.com/packer-with-azure-build-automated-machine-images-4ccb104faf4f
  - packer user vars ref: https://www.packer.io/docs/templates/user-variables.html
  - packer shell provisioners ref: https://www.packer.io/docs/provisioners/shell.html
  - B-series burstable virtual machine sizes ref: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable

  - Create 'packer-rg' resource group from Azure Portal.
  - Use 'build.sh' to start with new image build.
  - Show the latest image.

```
az image list --resource-group packer-rg -o json | jq .'[]'.id
```

  - Delete image whenever need to update it.

```
az image delete -n Ubuntu_image_1804_lts --resource-group packer-rg
```
