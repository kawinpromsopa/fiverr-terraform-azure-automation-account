##
## Automation account
##

output "automation_account_id" {
  description = "ID of the automation account."
  value       = element(concat(azurerm_automation_account.this.*.id, list("")), 0)
}


##
## Automation account schedule
##

output "automation_schedule_ids" {
  description = "IDs of the automation schedules."
  value       = compact(concat(azurerm_automation_schedule.this.*.id, [""]))
}

##
## Automation account job schedule
##

output "automation_account_job_ids" {
  description = "Ids of the automation job schedule."
  value       = compact(concat(azurerm_automation_job_schedule.this.*.id, [""]))
}

output "automation_account_job_schedule_ids" {
  description = "The UUID identifying the automation job schedule."
  value       = compact(concat(azurerm_automation_job_schedule.this.*.job_schedule_id, [""]))
}

##
## Automation module
##

output "automation_module_ids" {
  description = "IDs of the automation module."
  value       = compact(concat(azurerm_automation_module.this_module.*.id, [""]))
}

##
## Automation account runbook
##

output "automation_account_runbook_ids" {
  description = "IDs of the automation account runbook."
  value       = compact(concat(azurerm_automation_runbook.this_runbook.*.id, [""]))
}
