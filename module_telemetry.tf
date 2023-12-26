resource "modtm_telemetry" "this" {
  tags = {

  }
  ephemeral_number = 15119

  lifecycle {
    ignore_changes = [ephemeral_number]
  }
}