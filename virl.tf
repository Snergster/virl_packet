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
        operating_system = "ubuntu_16_04_image"
        billing_cycle = "hourly"
        project_id = "${packet_project.virl_project.id}"
        depends_on = ["packet_ssh_key.virlkey","packet_project.virl_project"]

# Alternate project_id. If you use a consistent project defined in settings.tf, uncomment the two lines below. Remember to comment out the two lines above!
# Only have one project_id and depends_on defined at a time
        #project_id = "${var.packet_project_id}"
        #depends_on = ["packet_ssh_key.virlkey"]


  connection {
        type = "ssh"
        user = "root"
        port = 22
        timeout = "1200"
        private_key = "${file("${var.ssh_private_key}")}"
      }

   provisioner "remote-exec" {
      inline = [
    # dead mans timer
        "apt-get update",
        "apt-get install at time -y",
        "printf '/usr/bin/curl -H X-Auth-Token:${var.packet_api_key} -X DELETE https://api.packet.net/devices/${packet_device.virl.id}\n'>/etc/deadtimer",
        "sleep 3",
        "at now + ${var.dead_mans_timer} hours -f /etc/deadtimer"
    ]
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
        source = "conf/install_salt.sh"
        destination = "/root/install_salt.sh"
    }
    provisioner "file" {
        source = "conf/logging.conf"
        destination = "/etc/salt/minion.d/logging.conf"
    }
    provisioner "file" {
        source = "conf/ubuntu-default.list"
        destination = "/etc/apt/sources.list.d/ubuntu-default.list"
    }
    provisioner "file" {
        source = "conf/${var.packet_location}.sources.list"
        destination = "/etc/apt/sources.list"
    }
    provisioner "file" {
        source = "conf/apt.conf"
        destination = "/etc/apt/apt.conf"
    }
   provisioner "remote-exec" {
      inline = [
         "apt-get update -qq",
         "apt-get install crudini at -y",
         "service atd start",
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
         "apt-get install openssh-server build-essential python-dev git ntp traceroute ntpdate zile curl traceroute unzip at swig libssl-dev sshpass crudini debconf-utils dkms qemu-kvm gcc cpu-checker openssl apt-show-versions htop apache2 libapache2-mod-wsgi mtools socat crudini telnet -y",
         "echo '*****************************************PRESALT STATE COMPLETED******************************'",
         "sleep 1 || true",
         "echo 'wget -O install_salt.sh https://bootstrap.saltstack.com'",
         "echo '*****************************************PRESALT STATE COMPLETED******************************'",
         "sleep 6 || true",
         "sh ./install_salt.sh -X -P stable",
    # create virl user
         "salt-call state.sls common.users",
    # copy authorized keys from root to virl user
         "salt-call grains.setval mitaka true",
         "salt-call grains.setval mysql_password ${var.mysql_password}",
         "salt-call file.write /etc/salt/minion.d/openstack.conf 'mysql.pass: ${var.mysql_password}'",
         "salt-call state.sls virl.packet.keycopy",
         "salt-call state.highstate",
         "salt-call state.sls virl.basics",
         "salt-call state.sls --state-output=changes common.submaster.getip",
         "echo '*****************************************BASICS STATE COMPLETED******************************'",
         "sleep 6 || true",
         "time salt-call -l info state.sls openstack",
         "salt-call state.sls openstack.restart",
         "salt-call state.sls openstack.neutron",
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
