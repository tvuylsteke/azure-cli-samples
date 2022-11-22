# Check if needed modules are installed if not install them
if (Get-Module -ListAvailable -Name Az.SecurityInsights) {
    Write-Host "Module Az.SecurityInsights exists"
} 
else {
    Write-Host "Module Az.SecurityInsights does not exist, installing it."
    install-module Az.SecurityInsights
}
if (Get-Module -ListAvailable -Name powershell-yaml) {
    Write-Host "Module powershell-yaml exists"
} 
else {
    Write-Host "Module powershell-yaml does not exist, installing it."
    install-module powershell-yaml
}

#dependency
. .\alertRuleFromGHToSentinel.ps1

$rulePath = "C:\git\Azure-Sentinel\Detections"
$allRuleFiles = gci $rulePath -Recurse | where {$_.extension -eq ".yaml"}

#testFile
$ruleFileContent = gc $allRuleFiles[305].FullName
#test
#$connectors = @()
#$ruleFile | foreach {if($_ -match "connectorId:"){$connectors += $_.Split(":")[1].Trim()}}

#construct dictionary the lazy way
#$dictionary = @{}
#foreach($file in $allRuleFiles){
    #$ruleFileContent = gc $file.FullName
    #$connectors = @()
    #$ruleFileContent | foreach {if($_ -match "connectorId:"){$connectors += $_.Split(":")[1].Trim()}}    
    #$dictionary.add($file.FullName, $connectors)
#}

#construct dictionary the yaml way
$dictionary = @{}
foreach($file in $allRuleFiles){
    $ruleFileContent = gc $file.FullName
    $connectors = @()

    $yaml = $ruleFileContent | convertFrom-Yaml
    $requiredDataConnectors = @()
    $requiredDataConnectors = $yaml.requiredDataConnectors
    foreach ($element in $requiredDataConnectors){
        $connectors += $element["connectorId"]
    }
    $dictionary.add($file.FullName, $connectors)    
}

#search for a specific connectorID
$connectorId = "DNS"
$results =@()
foreach ($key in $dictionary.keys){
    if($dictionary[$key] -contains $connectorId){        
        $results += $key
    }
}

$results

$resourceGroupName = "sentinel"
$workspaceName = "sentinel-la"

# Existing Rules


#foreach($res in $results){
    $res = $results[0]
    $res = $res.Replace("C:\git\Azure-Sentinel\Detections\","https://raw.githubusercontent.com/Azure/Azure-Sentinel/master/Detections/")
    $gitHubRawUrl = $res.Replace("\","/")
    New-SingleAlertRuleFromGitHub -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -gitHubRawUrl $gitHubRawUrl -existingRules $existingRules
#}

https://github.com/jangeisbauer/sentinel/blob/main/alertRuleFromGHToSentinel.ps1
https://raw.githubusercontent.com/Azure/Azure-Sentinel/master/Detections/
https://github.com/sreedharande/Microsoft-Sentinel-As-A-Code/blob/main/Export_Analytical_Rules.ps1

$allRuleTemplates = Get-AzSentinelAlertRuleTemplate -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName

$connectorId = "DNS"
$results =@()
foreach ($template in $allRuleTemplates){
    $connectors = $template.requiredDataConnectors
    foreach ($connector in $connectors){
        if($connector.ConnectorId -eq $connectorId){
            $results += $template
        }
    }
}

$myRuleObject = $result[1]
#enable a single rule
#AlertRuleTemplateName is important as to match the created rule with the template
New-AzSentinelAlertRule -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName `
        -Scheduled -DisplayName $myRuleObject.DisplayName -Description $myRuleObject.Description -Query $myRuleObject.Query `
        -QueryFrequency $myRuleObject.QueryFrequency.Ticks -QueryPeriod $myRuleObject.QueryPeriod.Ticks -Severity $myRuleObject.Severity -TriggerThreshold $myRuleObject.TriggerThreshold -Enabled `
        -AlertRuleTemplateName $myRuleObject.Name



$existingRules = get-azsentinelalertrule -resourceGroupName $resourceGroupName -workspaceName $workspaceName 
Foreach($myRuleObject in $results){
    $existingRule = Get-AzSentinelAlertRule -resourceGroupName $resourceGroupName  -WorkspaceName $WorkspaceName -RuleName $myRuleObject.displayName -ErrorAction SilentlyContinue

    New-AzSentinelAlertRule -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName `
            -Scheduled -DisplayName $myRuleObject.DisplayName -Description $myRuleObject.Description -Query $myRuleObject.Query `
            -QueryFrequency $myRuleObject.QueryFrequency.Ticks -QueryPeriod $myRuleObject.QueryPeriod.Ticks -Severity $myRuleObject.Severity -TriggerThreshold $myRuleObject.TriggerThreshold -Enabled `
            -AlertRuleTemplateName $myRuleObject.Name
}

$AlertRuleTemplate = Get-AzSentinelAlertRuleTemplate -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -AlertRuleTemplateId "300ce9e4-abd6-4ce2-bb1e-8701a889b9ad"

