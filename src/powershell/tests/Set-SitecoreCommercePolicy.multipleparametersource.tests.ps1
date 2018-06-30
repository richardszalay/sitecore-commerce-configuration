. "$PSScriptRoot/utils/Assert-SitecoreCommercePolicy.ps1"

Get-Module SitecorecommerceConfiguration -All | Remove-Module
Import-Module "$PSScriptRoot\..\SitecoreCommerceConfiguration.psd1" -ErrorAction Stop

Describe 'Set-SitecoreCommercePolicy' {

    BeforeAll {
        # Enable FS mock
    }

    BeforeEach {
        Remove-Item "TestDrive:\*" -Recurse
        Copy-Item "$PSScriptRoot\fixtures" "TestDrive:\" -Recurse
    }

    AfterAll {
        # Disable FS mock
    }

    Context 'singleparametersource' {

        Context "-Path" {
            It "updates multiple files" {

            }

            It "warns if no files match" {

            }
        }

        Context "-SourcePolicies" {
            It "applies matching policies when an exact value does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -SourcePolicies @(
                        @{
                            '$type' = "Sitecore.Commerce.Core.GlobalEnvironmentPolicy, Sitecore.Commerce.Core";
                            'DefaultCurrency' = 'AUD'
                        },
                        @{
                            '$type' = "Sitecore.Commerce.Plugin.Tax.GlobalTaxPolicy2, Sitecore.Commerce.Plugin.Tax";
                            'PriceIncudesTax' = $true
                        }
                    ) `
                    -WarningVariable Warn `
                    -WarningAction SilentlyContinue

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Core.GlobalEnvironmentPolicy, Sitecore.Commerce.Core" `
                    -Properties @{
                        # New properties
                        "DefaultCurrency" = "AUD";
                        # Existing properties
                        "DefaultLocale" = "en";
                    }

                $Warn | Should -Not -BeNullOrEmpty
            }

            It "merges properties when the type matches exactly" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -SourcePolicies @(
                        @{
                            '$type' = "Sitecore.Commerce.Core.GlobalEnvironmentPolicy, Sitecore.Commerce.Core";
                            'DefaultCurrency' = 'AUD'
                        },
                        @{
                            '$type' = "Sitecore.Commerce.Plugin.Tax.GlobalTaxPolicy, Sitecore.Commerce.Plugin.Tax";
                            'PriceIncudesTax' = $true
                        }
                    )

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Core.GlobalEnvironmentPolicy, Sitecore.Commerce.Core" `
                    -Properties @{
                        # New properties
                        "DefaultCurrency" = "AUD";
                        # Existing properties
                        "DefaultLocale" = "en";
                    }
            }

            It "merges properties when matches via a wildcard" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -SourcePolicies @(
                        @{
                            '$type' = "*GlobalEnvironmentPolicy*";
                            'DefaultCurrency' = 'AUD'
                        },
                        @{
                            '$type' = "*GlobalTaxPolicy*";
                            'PriceIncudesTax' = $true
                        }
                    )

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Core.GlobalEnvironmentPolicy, Sitecore.Commerce.Core" `
                    -Properties @{
                        # New properties
                        "DefaultCurrency" = "AUD";
                        # Existing properties
                        "DefaultLocale" = "en";
                    }
            }

            It "applies matching policies when a wildcard value does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -SourcePolicies @(
                        @{
                            '$type' = "*GlobalEnvironmentPolicy*";
                            'DefaultCurrency' = 'AUD'
                        },
                        @{
                            '$type' = "*GlobalTaxPolicy2*";
                            'PriceIncudesTax' = $true
                        }
                    ) `
                    -WarningVariable Warn `
                    -WarningAction SilentlyContinue

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Core.GlobalEnvironmentPolicy, Sitecore.Commerce.Core" `
                    -Properties @{
                        # New properties
                        "DefaultCurrency" = "AUD";
                        # Existing properties
                        "DefaultLocale" = "en";
                    }

                $Warn | Should -Not -BeNullOrEmpty
            }
        }

        Context "-Force" {
            It "adds policy when exact type does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -SourcePolicies @(
                        @{
                            '$type' = "Sitecore.Commerce.Core.GlobalEnvironmentPolicy2, Sitecore.Commerce.Core";
                            'DefaultCurrency' = 'AUD'
                        },
                        @{
                            '$type' = "Sitecore.Commerce.Plugin.Tax.GlobalTaxPolicy2, Sitecore.Commerce.Plugin.Tax";
                            'PriceIncudesTax' = $true
                        }
                    ) `
                    -Force

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Core.GlobalEnvironmentPolicy2, Sitecore.Commerce.Core" `
                    -Properties @{
                        "DefaultCurrency" = "AUD";
                    }
            }

            It "warns when a wildcard value does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -SourcePolicies @(
                        @{
                            '$type' = "Sitecore.Commerce.Core.GlobalEnvironmentPolicy2, Sitecore.Commerce.Core";
                            'DefaultCurrency' = 'AUD'
                        },
                        @{
                            '$type' = "*GlobalTaxPolicy2*";
                            'PriceIncudesTax' = $true
                        }
                    ) `
                    -Force `
                    -WarningVariable Warn `
                    -WarningAction SilentlyContinue

                $Warn | Should -Not -BeNullOrEmpty
            }

            It "adds exact matches when wildcard does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -SourcePolicies @(
                        @{
                            '$type' = "Sitecore.Commerce.Core.GlobalEnvironmentPolicy2, Sitecore.Commerce.Core";
                            'DefaultCurrency' = 'AUD'
                        },
                        @{
                            '$type' = "*GlobalTaxPolicy2*";
                            'PriceIncudesTax' = $true
                        }
                    ) `
                    -Force `
                    -WarningAction SilentlyContinue

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.Habitat.CommerceShops-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Core.GlobalEnvironmentPolicy2, Sitecore.Commerce.Core" `
                    -Properties @{
                        "DefaultCurrency" = "AUD";
                    }
            }
        }
    }

}