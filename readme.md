## Instructions
Fork the repository and create a local clone of it. Change into the directory and run the following three commands to try the template out. For real production use you should of course provide the parameters dynamically instead of hard coding them into the .parameters.json file, especially the password.

If you are trying the script more than once, you will have to change the parameter *dnsLabelPrefix* since it must be unique.

#### Create a name that will be used for the resource group and name of the deployment
```
$name = "solr-rg10"
```

#### Create resource group
```
New-AzureRmResourceGroup -Name $name -Location "west europe"
```

#### Deploy the vm, using the parameters from the paratmer file
```
New-AzureRmResourceGroupDeployment -Name $name -ResourceGroupName $name -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json
```
