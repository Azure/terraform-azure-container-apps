resource "modtm_telemetry" "this" {
  tags = {

  }
  ephemeral_number = 2460

  lifecycle {
    ignore_changes = [ephemeral_number]
  }
}