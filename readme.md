$name = "solr-rg10"

New-AzureRmResourceGroup -Name $name -Location "west europe"

New-AzureRmResourceGroupDeployment -Name $name -ResourceGroupName $name -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json
