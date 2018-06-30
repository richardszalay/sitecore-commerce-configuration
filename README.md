PowerShell Cmdlets (and later VSTS Tasks) for configuring and boostrapping Commerce Engine environment policy configuration files.

## PowerShell Cmdlets

```PowerShell

# Update a single policy
Set-SitecoreCommercePolicy -Path "path\to\policy.json" -PolicyType "Fully.Qualified, Type" -Properties @{ "Property1" = "Value1"; "Property2" = "Value2" }

# Use -Force to add a policy that may not exist
Set-SitecoreCommercePolicy -Path "path\to\policy.json" -PolicyType "Fully.Qualified, Type" -Properties @{ "Property1" = "Value1"; "Property2" = "Value2" } -Force

# Update multiple policies
Set-SitecoreCommercePolicy -Path "path\to\policy.json" -SourcePolicies @(
	@{
		'$type' = "Fully.Qualified.Type, Note.The.SingleQuotes.On.$type",
		"Property1" = "Value1";
		"Property2" = "Value2";
	},
	@{
		'$type' = "Another.Type, Qualified",
		"Etc" = "Etc"
	}
)

```