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
