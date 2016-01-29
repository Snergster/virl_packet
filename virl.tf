# Configure the Packet Provider
provider "packet" {
        auth_token = "${var.packet_api_key}"
}

# comment next three lines out if you wish to use a consistent project
#resource "packet_project" "virl_project" {
#        name = "virl server on packet"
#}

resource "packet_ssh_key" "virlkey" {
        name = "virlkey"
        public_key = "${file("${var.ssh_private_key}.pub")}"
}

# 
resource "packet_device" "virl" {
        hostname = "${var.hostname}"
        plan = "${var.packet_machine_type}"
        facility = "ewr1"
        operating_system = "ubuntu_14_04"
        billing_cycle = "hourly"
#        project_id = "${packet_project.virl_project.id}"

# Alternate project_id if you use a consistent project defined in variables.tf
# Only have one project_id defined at a time
        project_id = "${var.packet_project_id}"

        depends_on = ["packet_ssh_key.virlkey"]#,"packet_project.virl_project"]


  connection {
        type = "ssh"
        user = "root"
        port = 22
        timeout = "1200"
        private_key = "${var.ssh_private_key}"
      }

   provisioner "remote-exec" {
      inline = [
        "mkdir -p /etc/salt/minion.d",
        "mkdir -p /etc/salt/pki/minion"
    ]
    }
    provisioner "file" {
        source = "keys/"
        destination = "/etc/salt/pki/minion"
    }
    provisioner "file" {
        source = "conf/virl.ini"
        destination = "/etc/virl.ini"
    }
    provisioner "file" {
        source = "conf/extra.conf"
        destination = "/etc/salt/minion.d/extra.conf"
    }

   provisioner "remote-exec" {
      inline = [
         "apt-get install crudini -y",
         "printf '\nmaster: ${var.salt_master}\nid: ${var.salt_id}\nappend_domain: ${var.salt_domain}\n' >>/etc/salt/minion.d/extra.conf",
         "crudini --set /etc/virl.ini DEFAULT salt_id ${var.salt_id}",
         "crudini --set /etc/virl.ini DEFAULT salt_master ${var.salt_master}",
         "crudini --set /etc/virl.ini DEFAULT salt_domain ${var.salt_domain}",
         "crudini --set /etc/virl.ini DEFAULT guest_password ${var.guest_password}",
         "crudini --set /etc/virl.ini DEFAULT uwmadmin_password ${var.uwmadmin_password}",
         "crudini --set /etc/virl.ini DEFAULT password ${var.openstack_password}",
         "crudini --set /etc/virl.ini DEFAULT mysql_password ${var.mysql_password}",
         "crudini --set /etc/virl.ini DEFAULT keystone_service_token ${var.openstack_token}",
         "crudini --set /etc/virl.ini DEFAULT openvpn_enable ${var.openvpn_enable}",
         "crudini --set /etc/virl.ini DEFAULT hostname ${var.hostname}"
    ]
    }

/* comment multiline */
   provisioner "remote-exec" {
      inline = [
         "set -e",
         "set -x",
         "wget -O install_salt.sh https://bootstrap.saltstack.com",
         "sh ./install_salt.sh -P git v2015.8.3",
         "salt-call state.sls common.users",
         "salt-call state.highstate",
         "salt-call state.sls virl.basics",
         "printf '/usr/bin/curl -H X-Auth-Token:${var.packet_api_key} -X DELETE https://api.packet.net/devices/${packet_device.virl.id}\n'>/etc/deadtimer",
         "at now + ${var.dead_mans_timer} hours -f /etc/deadtimer",
         "salt-call state.sls openstack",
         "/usr/local/bin/vinstall salt",
         "salt-call state.sls openstack.setup",
         "salt-call state.sls common.bridge",
         "salt-call state.sls openstack.restart",
         "salt-call state.sls virl.std",
         "salt-call state.sls virl.ank",
         "salt-call state.sls virl.guest",
         "salt-call state.sls openstack.restart",
         "salt-call state.sls virl.routervms",
         "salt-call state.sls virl.openvpn",
         "salt-call state.sls virl.openvpn.packet",
         "reboot"
   ]
  }

#
}
