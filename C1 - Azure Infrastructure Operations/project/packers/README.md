#### How to build VM image with packer

  - Create 'packer-rg' resource group from Azure Portal.
  - Use 'build.sh' to start with new image build with packer.

```
./build.sh
```

  - Show the latest image.

```
az image list --resource-group packer-rg -o json | jq .'[]'.id
```

  - Delete image whenever need to update existing one it.

```
az image delete -n Ubuntu_image_1804_lts --resource-group packer-rg
```

#### References

  1. [Packer guide](https://subramanisundaram.medium.com/packer-with-azure-build-automated-machine-images-4ccb104faf4f)
  2. [Packer user vars](https://www.packer.io/docs/templates/user-variables.html)
  3. [Packer shell provisioners](https://www.packer.io/docs/provisioners/shell.html)
  4. [Choose B-series burstable virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable)

