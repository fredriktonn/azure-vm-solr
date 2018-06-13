## In a Powershell prompt run the following three commands

### Create a name that will be used for the resource group and name of the deployment
```
$name = "solr-rg10"
```

### Create resource group
```
New-AzureRmResourceGroup -Name $name -Location "west europe"
```

### Deploy the vm, using the parameters from the paratmer file
```
New-AzureRmResourceGroupDeployment -Name $name -ResourceGroupName $name -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json
```
