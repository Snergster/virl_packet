variable "salt_master" {
	description = "ip address of salt master"
	default = "147.75.195.163"
}

variable "salt_id" {
	description = "your salt_id"
	default = "virl"
}

variable "salt_domain" {
	description = "salt_domain"
	default = "virl.info"
}

variable "hostname" {
	description = "Hostname for packet and machine"
	default = "vtest2"
}

variable "packet_machine_type" {
	description = "set to either baremetal_1 or barebetal_3"
	default = "baremetal_1"
}
variable "packet_project_id" {
	description = "After you create packet project, attach your ssh key, get your api key, then get id key with curl -H 'X-Auth-Token: putAPIkeyhere' https://api.packet.net/projects"
    default = "bad_project_id"
}

variable "packet_api_key" {
	description = "get your packet api key at https://app.packet.net/portal#/api-keys "
    default = "bad_api_key"
}

variable "guest_password" {
	description = "password for the guest account"
	default = "321guest123"
}

variable "uwmadmin_password" {
	description = "password for the uwm admin account"
	default = "321guest123"
}

variable "openstack_password" {
	description = "password for openstack admin account"
	default = "123password321"
}

variable "mysql_password" {
	description = "password for mysql"
	default = "123mypass321"
}

variable "openstack_token" {
	description = "password for keystone token"
	default = "123token321"
}
