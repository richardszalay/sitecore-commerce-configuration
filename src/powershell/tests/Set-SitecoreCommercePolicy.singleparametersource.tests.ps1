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

        Context "-PolicyType" {
            It "warns when exact value does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.SQL.EntityStoreSqlPolicy2, Sitecore.Commerce.Plugin.SQL" `
                    -Properties @{
                        "Password" = "test-pass"
                    } `
                    -WarningVariable Warn `
                    -WarningAction SilentlyContinue

                $Warn | Should -Not -BeNullOrEmpty
            }

            It "merges properties when the type matches exactly" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.SQL.EntityStoreSqlPolicy, Sitecore.Commerce.Plugin.SQL" `
                    -Properties @{
                        "Password" = "test-pass"
                    }

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.SQL.EntityStoreSqlPolicy, Sitecore.Commerce.Plugin.SQL" `
                    -Properties @{
                        # New properties
                        "Password" = "test-pass";
                        # Existing properties
                        "Database" = "SitecoreCommerce9_SharedEnvironments";
                        "ConnectTimeout" = 120000
                    }
            }

            It "merges properties when matches via a wildcard" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "*EntityStoreSqlPolicy*" `
                    -Properties @{
                        "Password" = "test-pass"
                    }

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.SQL.EntityStoreSqlPolicy, Sitecore.Commerce.Plugin.SQL" `
                    -Properties @{
                        # New properties
                        "Password" = "test-pass";
                        # Existing properties
                        "Database" = "SitecoreCommerce9_SharedEnvironments";
                        "ConnectTimeout" = 120000
                    }
            }

            It "warns when a wildcard value does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "*EntityStoreSqlPolicy2*" `
                    -Properties @{
                        "Password" = "test-pass"
                    } `
                    -WarningVariable Warn `
                    -WarningAction SilentlyContinue

                $Warn | Should -Not -BeNullOrEmpty
            }
        }

        Context "-Force" {
            It "adds policy when exact type does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.SQL.EntityStoreSqlPolicy2, Sitecore.Commerce.Plugin.SQL" `
                    -Properties @{
                        "Password" = "test-pass"
                    } `
                    -Force

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.SQL.EntityStoreSqlPolicy2, Sitecore.Commerce.Plugin.SQL" `
                    -Properties @{
                        # New properties
                        "Password" = "test-pass";
                    }
            }

            It "warns when a wildcard value does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "*EntityStoreSqlPolicy2*" `
                    -Properties @{
                        "Password" = "test-pass"
                    } `
                    -Force `
                    -WarningVariable Warn `
                    -WarningAction SilentlyContinue

                $Warn | Should -Not -BeNullOrEmpty
            }
        }

        Context "-PolicyFilter" {
            It "filters matching policies using the supplied block" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.CatalogIndexing.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.Catalog.SitecoreCatalogIndexingPolicy, Sitecore.Commerce.Plugin.Catalog" `
                    -PolicyFilter {
                        $_.Name -eq "SellableItemsIndexMaster"
                    } `
                    -Properties @{
                        "IncrementalListName" = "SellableItemsIncrementalIndexMaster2"
                    }
    
                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.CatalogIndexing.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.Catalog.SitecoreCatalogIndexingPolicy, Sitecore.Commerce.Plugin.Catalog" `
                    -PolicyFilter {
                        $_.Name -eq "SellableItemsIndexMaster"
                    } `
                    -Properties @{
                        "IncrementalListName" = "SellableItemsIncrementalIndexMaster2"
                    }

                Assert-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\PlugIn.CatalogIndexing.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.Catalog.SitecoreCatalogIndexingPolicy, Sitecore.Commerce.Plugin.Catalog" `
                    -PolicyFilter {
                        $_.Name -eq "SellableItemsIndexWeb"
                    } `
                    -Properties @{
                        "IncrementalListName" = "SellableItemsIncrementalIndexWeb"
                    }
            }

            It "warns when property filter does not match" {
                Set-SitecoreCommercePolicy `
                    -Path "TestDrive:\fixtures\default\Plugin.SQL.PolicySet-1.0.0.json" `
                    -PolicyType "Sitecore.Commerce.Plugin.Catalog.SitecoreCatalogIndexingPolicy, Sitecore.Commerce.Plugin.Catalog" `
                    -PolicyFilter {
                        $_.Name -eq "SellableItemsIndexWeb"
                    } `
                    -Properties @{
                        "IncrementalListName" = "SellableItemsIncrementalIndexWeb"
                    } `
                    -WarningVariable Warn `
                    -WarningAction SilentlyContinue

                $Warn | Should -Not -BeNullOrEmpty
            }
        }
    }

}