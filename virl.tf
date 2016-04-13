# Configure the Packet Provider
provider "packet" {
        auth_token = "${var.packet_api_key}"
}

# comment next three lines out if you wish to use a consistent project
resource "packet_project" "virl_project" {
        name = "virl server on packet"
}

resource "packet_ssh_key" "virlkey" {
        name = "virlkey"
        public_key = "${file("${var.ssh_private_key}.pub")}"
}

# 
resource "packet_device" "virl" {
        hostname = "${var.hostname}"
        plan = "${var.packet_machine_type}"
        facility = "${var.packet_location}"
        operating_system = "ubuntu_14_04"
        billing_cycle = "hourly"
        project_id = "${packet_project.virl_project.id}"
        depends_on = ["packet_ssh_key.virlkey","packet_project.virl_project"]

# Alternate project_id. If you use a consistent project defined in variables.tf, uncomment the line below. Remember to comment out the two lines above!
# Only have one project_id and depends_on defined at a time
        #project_id = "${var.packet_project_id}"
        #depends_on = ["packet_ssh_key.virlkey"]


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
    provisioner "file" {
        source = "conf/logging.conf"
        destination = "/etc/salt/minion.d/logging.conf"
    }

   provisioner "remote-exec" {
      inline = [
         "apt-get install crudini at -y",
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
         "sh ./install_salt.sh -X -P stable",
    # create virl user
         "salt-call state.sls common.users",
    # copy authorized keys from root to virl user
         "salt-call state.sls virl.packet.keycopy",
         "salt-call state.highstate",
         "salt-call state.sls virl.basics",
    # dead mans timer
         "printf '/usr/bin/curl -H X-Auth-Token:${var.packet_api_key} -X DELETE https://api.packet.net/devices/${packet_device.virl.id}\n'>/etc/deadtimer",
         "sleep 3",
         "at now + ${var.dead_mans_timer} hours -f /etc/deadtimer",
         "time salt-call -l info state.sls openstack",
         "echo '*****************************************OPENSTACK STATE COMPLETED******************************'",
         "/usr/local/bin/vinstall salt",
         "salt-call state.sls openstack.keystone.apache2",
         "salt-call state.sls openstack.setup",
         "echo '*****************************************OPENSTACK SETUP STATE COMPLETED******************************'",
         "salt-call state.sls common.bridge",
         "salt-call state.sls openstack.restart",
         "salt-call state.sls virl.std",
         "salt-call state.sls virl.ank",
         "salt-call state.sls virl.guest",
         "salt-call state.sls openstack.restart",
         "salt-call state.sls virl.ramdisk",
         "salt-call state.sls virl.routervms",
         "salt-call state.sls virl.openvpn",
         "echo '*****************************************OPENVPN STATE COMPLETED******************************'",
         "salt-call -l info state.sls virl.openvpn.packet",
         "echo '*****************************************OPENVPN PACKET STATE COMPLETED******************************'",
    #This is to keep the sftp from failing and taking terraform out with it in case no vpn is actually installed
         "touch /var/local/virl/client.ovpn"

   ]
  }
    provisioner "local-exec" {
        command = "sftp -o 'IdentityFile=${var.ssh_private_key}' -o 'StrictHostKeyChecking=no' root@${packet_device.virl.network.0.address}:/var/local/virl/client.ovpn client.ovpn"
    }
#
   provisioner "remote-exec" {
      inline = [
        "sleep 5",
        "reboot"
        ]
        }
  }

#
