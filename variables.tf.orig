variable "packet_api_key" {
	description = "get your packet api key at https://app.packet.net/portal#/api-keys "
    default = "bad_api_key"
}

variable "packet_project_id" {
	description = "After you create packet project, attach your ssh key, get your api key, then get id key with curl -H 'X-Auth-Token: putAPIkeyhere' https://api.packet.net/projects"
    default = "bad_project_id"
}

variable "salt_master" {
	description = "ip address of salt master"
	default = "ewr-packet-1.virl.info"
}

variable "salt_id" {
	description = "your salt_id"
	default = "badsaltid"
}

variable "salt_domain" {
	description = "salt_domain"
	default = "virl.info"
}

variable "hostname" {
	description = "Hostname for packet and machine"
	default = "virltest"
}

variable "packet_machine_type" {
	description = "set to either baremetal_1 or barebetal_3"
	default = "baremetal_1"
}

variable "guest_password" {
	description = "password for the guest account - stick with letters and numbers for now please"
	default = "321guest123"
}

variable "ssh_private_key" {
	description = "location of ssh private key that matches the public key you gave to packet"
	default = "~/.ssh/id_rsa"
}

variable "uwmadmin_password" {
	description = "password for the uwm admin account - stick with letters and numbers for now please"
	default = "321uwmp123"
}

variable "openstack_password" {
	description = "password for openstack admin account - max 10 characters - stick with letters and numbers for now please"
	default = "123pass321"
}

variable "mysql_password" {
	description = "password for mysql - max 10 characters - stick with letters and numbers for now please"
	default = "123mysq321"
}

variable "openstack_token" {
	description = "password for keystone token"
	default = "123token321"
}
