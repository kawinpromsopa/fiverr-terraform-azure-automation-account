locals {
  should_create_automation_module            = var.enabled && var.module_enabled
  should_create_automation_runbook           = var.enabled && var.runbook_enabled
  should_create_automation_account           = var.enabled && var.automation_account_enabled
  should_create_automation_schedule          = var.enabled && var.automation_schedule_enabled
  should_create_automation_job_schedule      = var.enabled && var.automation_job_enabled
}

##
## Automation account
##

resource "azurerm_automation_account" "this" {
  count = local.should_create_automation_account ? 1 : 0

  name                = var.automation_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name

  tags = merge(
    var.tags,
    var.automation_account_tags,
    {
      "Terraform" = "true"
    }
  )
}

##
## Automation account schedule
##

resource "azurerm_automation_schedule" "this" {
  count = local.should_create_automation_schedule ? length(var.schedule_names) : 0

  name                    = element(var.schedule_names, count.index)
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_exist == false ? element(concat(azurerm_automation_account.this.*.name, list("")), 0) : element(var.existing_automation_account_names, count.index)
  frequency               = element(var.schedule_frequencies, count.index)
  description             = element(var.schedule_descriptions, count.index)
  interval                = element(var.schedule_frequencies, count.index) != "OneTime" ? element(var.schedule_intervals, count.index) : null
  start_time              = element(var.schedule_start_times, count.index)
  expiry_time             = element(var.schedule_expiry_times, count.index)
  timezone                = element(var.schedule_timezones, count.index)
  week_days               = element(var.schedule_frequencies, count.index) == "Week" ? element(var.schedule_weekdays, count.index) : null
  month_days              = element(var.schedule_frequencies, count.index) == "Month" ? element(var.schedule_month_days, count.index) : null

  dynamic "monthly_occurrence" {
    for_each = element(var.schedule_frequencies, count.index) == "Month" ? [1] : []

    content {
      day        = element(var.monthly_occurrence_days, count.index)
      occurrence = element(var.monthly_occurrence_occurrences, count.index)
    }
  }

  depends_on = [azurerm_automation_account.this]
}

##
## Automation account job schedule
##

resource "azurerm_automation_job_schedule" "this" {
  count = local.should_create_automation_job_schedule ? length(var.automation_job_schedule_names) : 0

  schedule_name           = element(var.automation_job_schedule_names, count.index)
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_exist == false ? element(concat(azurerm_automation_account.this.*.name, list("")), 0) : element(var.existing_automation_account_names, count.index)
  runbook_name            = element(var.automation_job_schedule_runbook_names, count.index)
  parameters              = element(var.automation_job_schedule_parameters, count.index)
  run_on                  = element(var.automation_job_schedule_run_on, count.index)

  depends_on = [azurerm_automation_schedule.this]
}

##
## Automation module
##

resource "azurerm_automation_module" "this_module" {
  count = local.should_create_automation_module ? length(var.module_names) : 0

  name                    = element(var.module_names, count.index)
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_exist == false ? element(concat(azurerm_automation_account.this.*.name, list("")), 0) : element(var.existing_automation_account_names, count.index)

  dynamic "module_link" {
    for_each = element(var.module_link_uris, count.index) != null ? [1] : []

    content {
      uri = element(var.module_link_uris, count.index)
    }
  }
}

##
## Automation account runbook
##

resource "azurerm_automation_runbook" "this_runbook" {
  count = local.should_create_automation_runbook ? length(var.runbook_names) : 0

  name                    = element(var.runbook_names, count.index)
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = var.automation_account_exist == false ? element(concat(azurerm_automation_account.this.*.name, list("")), 0) : element(var.existing_automation_account_names, count.index)
  runbook_type            = element(var.runbook_types, count.index)
  log_progress            = element(var.runbook_log_progress, count.index)
  log_verbose             = element(var.runbook_log_verbose, count.index)
  description             = element(var.runbook_descriptions, count.index)
  content                 = element(var.runbook_contents, count.index)

  dynamic "publish_content_link" {
    for_each = element(var.publish_content_link_uris, count.index) != null ? [1] : []

    content {
      uri = element(var.publish_content_link_uris, count.index)
    }
  }

  tags = merge(
    var.tags,
    var.runbook_tags,
    {
      "Terraform" = "true"
    }
  )
}
