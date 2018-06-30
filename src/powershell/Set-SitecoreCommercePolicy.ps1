function Set-SitecoreCommercePolicy {
    [CmdletBinding(DefaultParameterSetName = 'singleparametersource')]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(ParameterSetName='multipleparametersource')]
        [Hashtable[]]$SourcePolicies,

        [Parameter(ParameterSetName='singleparametersource', Mandatory=$true)]
        [string]$PolicyType,
        
        [Parameter(ParameterSetName='singleparametersource', Mandatory=$false)]
        [ScriptBlock]$PolicyFilter,

        [Parameter(ParameterSetName='singleparametersource', Mandatory=$true)]
        [Hashtable]$Properties,

        [switch]$Force
    )

    function NormalizeTypeName([string]$typeName) {
        return $typeName -replace " ",""
    }

    $SourcePolicies = if ($PSCmdlet.ParameterSetName -eq "singleparametersource") {
        $clonedProperties = $Properties.Clone()
        $clonedProperties['$type'] = $PolicyType
        @($clonedProperties)
    } else {
        @($SourcePolicies)
    }

    $targetJson = Get-Content -Path $Path -Raw | ConvertFrom-Json

    $targetJsonPolicies = $targetJson.Policies.'$values'

    $SourcePolicies | Foreach-Object {

        $sourcePolicy = $_

        $targetPolicyIndex =  (0..(@($targetJsonPolicies).Count-1)) | Where-Object { 
            $targetPolicy = $targetJson.Policies.'$values'[$_]
            if (-not ((NormalizeTypeName $targetPolicy.'$type') -like (NormalizeTypeName $sourcePolicy.'$type'))) {
                return $false
            }
            
            if ($PolicyFilter) {
                if (@($targetPolicy) | Where-Object $PolicyFilter) {
                    return $true
                } else {
                    return $false
                }
            }
            
            return $true
        }

        if ($targetPolicyIndex -eq $null) {
            $sourcePolicyType = $sourcePolicy.'$type'

            if ($Force -and (-not ($sourcePolicyType -match '\*'))) {
                $targetPolicy = @{
                    '$type' = $sourcePolicyType
                }
                $targetJson.Policies.'$values' += @($targetPolicy)
            } else {
                if ($PolicyFilter) {
                    Write-Warning "No matching policy found for $sourcePolicyType using the supplied PolicyFilter"
                } else {
                    Write-Warning "No matching policy found for $sourcePolicyType"
                }
                return                
            }
        } else {
            $targetPolicy = $targetJson.Policies.'$values'[$targetPolicyIndex].psobject.properties | % { $ht = @{} } { $ht[$_.Name] = $_.Value } { $ht } 

            $targetJson.Policies.'$values'[$targetPolicyIndex] = $targetPolicy
        }

        $sourcePolicy.Keys | Where-Object { $_ -ne '$type' } | Foreach-Object {
            $targetPolicy[$_] = $sourcePolicy[$_]
        }
    }

    Set-Content -Path $Path -Value ($targetJson | ConvertTo-Json -Depth 100)
}

Export-ModuleMember Set-SitecoreCommercePolicy