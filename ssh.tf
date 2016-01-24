resource "packet_ssh_key" "virlkey" {
name = "virlkey"
public_key = "${var.ssh_private_key}.pub"
}
