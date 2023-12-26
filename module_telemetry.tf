resource "modtm_telemetry" "this" {
  tags = {

    avm_git_commit           = "90344ae1b45723b86bc7448a23dd5ff00ea5c561"
    avm_git_file             = "module_telemetry.tf"
    avm_git_last_modified_at = "2023-12-26 05:13:34"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azure-container-apps"
    avm_yor_name             = "this"
    avm_yor_trace            = "593126ab-1764-4c5b-a606-2fc144f39629"
  }
  ephemeral_number = 15119

  lifecycle {
    ignore_changes = [ephemeral_number]
  }
}