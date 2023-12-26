resource "modtm_telemetry" "this" {
  tags = {

    avm_git_commit           = "a45831466a9cd0ac82c91990d3f6d8bcdcad7061"
    avm_git_file             = "module_telemetry.tf"
    avm_git_last_modified_at = "2023-12-26 06:39:19"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azure-container-apps"
    avm_yor_name             = "this"
    avm_yor_trace            = "751bdfff-ae35-4656-9e52-079b12341082"
  }
  ephemeral_number = 17807

  lifecycle {
    ignore_changes = [ephemeral_number]
  }
}