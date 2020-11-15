# Terraform which creates resources on Azure.

## Prerequisites
- Terraform v0.12.25
- provider.azurerm v2.20.0
- az cli

These types of resources are supported:

- Resource group
- Automation Account
   - Runbook
   - Schedule

### Custom powershell script at:

- `./deploy/runbook/script.ps1`

### Usage

- `deploy/main.tf`

```
provider "azurerm" {
  features {}
  version         = ">= 2.0.0"
}

resource "random_string" "default" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "default" {
  name     = "resource-group-${random_string.default.result}"
  location = "Southeast Asia"
}

data "local_file" "default" {
  filename = "${path.root}/runbook/script.ps1"
}

module "automation_account" {
  source = "../."

  automation_account_enabled = true
  automation_account_name    = "automation-account-${random_string.default.result}"
  resource_group_name        = "${azurerm_resource_group.default.name}"
  location                   = "${azurerm_resource_group.default.location}"
  sku_name                   = "Basic"

  automation_schedule_enabled = true
  schedule_names              = ["automation-account-schedule-${random_string.default.result}"]
  schedule_frequencies        = ["Week"]
  schedule_descriptions       = ["This is an example schedule description"]
  schedule_intervals          = [1]
  schedule_start_times        = ["2020-12-15T18:30:00Z"]
  schedule_expiry_times       = ["2020-12-15T20:30:00Z"]
  schedule_timezones          = ["UTC"]
  schedule_weekdays           = [["Monday", "Friday"]]

  ## NOTE: When some modules importing failed, Delete that module on Azure console and terraform reapply new.
  module_enabled   = true
  module_names     = ["Az.Accounts", "Az.Compute", "Az.Network"]
  module_link_uris = ["https://www.powershellgallery.com/api/v2/package/Az.Accounts/2.1.2", "https://www.powershellgallery.com/api/v2/package/Az.Compute/4.6.0", "https://www.powershellgallery.com/api/v2/package/Az.Network/4.2.0"]

  runbook_enabled           = true
  runbook_names             = ["automation-account-runbook${random_string.default.result}"]
  runbook_log_verbose       = [true]
  runbook_log_progress      = [true]
  runbook_types             = ["PowerShell"]
  runbook_descriptions      = ["This is an example runbook description"]
  runbook_contents          = ["${data.local_file.default.content}"]
  publish_content_link_uris = ["https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"]
}
```


### Authenticate and terraform init, apply under `./deploy` directory.
```
az login
terraform init
terraform apply 
```

- NOTE: After you have deployed, You should create the `RunAsAccount` on Azure console at automation account service to provide privilege execution runbook.
