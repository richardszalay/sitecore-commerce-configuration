function Assert-SitecoreCommercePolicy {
    param(
        [string]$Path,
        [string]$PolicyType,
        [ScriptBlock]$PolicyFilter,
        [Hashtable]$Properties
    )

    $targetJson = Get-Content -Path $Path -Raw | ConvertFrom-Json

    $targetPolicies = $targetJson.Policies.'$values'

    $PolicyType | Should -BeIn @($targetPolicies | %{ $_.'$type' })

    $matchingPolicies = $targetJson.Policies.'$values' |
        Where-Object { $_.'$type' -eq $PolicyType }

    if ($PolicyFilter) {
        $matchingPolicies = $matchingPolicies | Where-Object $PolicyFilter
    }

    $matchingPolicies | ForEach-Object {
        $matchingPolicy = $_

        foreach($k in $Properties.Keys) {
            $matchingPolicy."$k" | Should -Be $Properties[$k]
        }
    }
}