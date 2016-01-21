    output "ip" {
      value = "${packet_device.virl_test.network.0.address}"
    }
    output "uwm" {
      value = "http://${packet_device.virl_test.network.0.address}:19400"
    }
