# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Verify all tooling versions. Upon the test, I use the versions that run on MacOS. When you have unexpected results from project clone, that could be introduction of related issues from tool versions.

```
* az --version
azure-cli                         2.15.1

* terraform - version
Terraform v0.12.29

* packer version
Packer v1.6.5
```

2. Note to follow each step in order to get a well-planned result.

3. Deploying Your Infrastructure.

   - Open subfolder 'custom-policies' and run install.sh. Consult README.md in subfolder to get a clean start.

   - Open subfolder 'packer' and run build.sh. Consult README.md in subfolder to get a clean start.

   - Open subfolder 'terraform' and run install.sh. Consult README.md in subfolder to get a clean start.

### Output

1. Use README.md in the subfolder in each step to acknowledge what outputs look like after run.
