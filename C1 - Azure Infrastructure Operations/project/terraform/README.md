#### Use terraform to create the infrastructure.

- Change 'terraform.tfvars' parameters to meet your requirements.

```
prefix         = "A prefix string to use to declare prefix resource name"
location       = "A regional location"
role           = "A role name assigned to specific resource in this project"
number-of-vms  = "A number of VM instances"
linux-vm-image = {
  id = "A parameter Image ID that produces from packer building process"
}
```

- Steps to deploy infrastructure with terraform.

```
- Create a resource group
- Create a virtual network and a subnet on that network
- Create a Network Security Group. 
  
  * Allows VMs to communicate in the networks
  * Deny all ingress traffic except for port 80

- Create a network interface.
- Create a public IP.
- Create a load balancer. 

  * Create backend address pool.
  * Create pool association for network interfaces and load balancer.
  * Create load balancer healthcheck rule.
  * Create load balancer healthcheck probe.

- Create a availability set. (In southeast region, Fault domain <= 2)
- Create VMs 
  
  * Pass vm image Id from packer from terraform.tfvars
- Create managed disks.
- Attach managed disks to VMs.
```


#### Outputs
  
- Plan output in 'solution.plan'

```
terraform plan -out solution.plan
```

- Deploy infrastructure and observe the outputs.

```
./install.sh

Outputs:

pool_member_vifs = [
  [
    "azure-vif0",
    "azure-vif1",
  ],
]
pool_member_vms = [
  [
    "azure-vm0",
    "azure-vm1",
  ],
]
public_ip = [
  [
    "13.67.64.173",
  ],
]

curl 13.67.64.173
Hello World!
```

#### How to evaluate the fault domain in region?

```
They are a number of fault domains for managed 'availability sets' by 
each region. 

By default, the virtual machines configured within your availability set 
are separated across up to three fault domains for Resource Manager 
deployments (two fault domains for Classic).

# checks the number of FDs in each region
az vm list-skus --resource-type availabilitySets \
  --query '[?name==`Aligned`].{Location:locationInfo[0].location, MaximumFaultDomainCount:capabilities[0].value}' -o Table
```
