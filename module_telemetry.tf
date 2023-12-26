resource "modtm_telemetry" "this" {
  tags = {

  }

  lifecycle {
    ignore_changes = [ephemeral_number]
  }
}