    output "ip" {
      value = "${packet_device.virl.network.0.address}"
    }
    output "uwm" {
      value = "http://${packet_device.virl.network.0.address}:19400"
    }
    output "uwm login" {
      value = "login uwmadmin password ${var.uwmadmin_password}"
    }
    output "guest login" {
      value = "login guest password ${var.guest_password}"
    }
