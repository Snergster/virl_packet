
#Steps:

0. install terraform.io to your VIRL Server. This is available from https://www.terraform.io/downloads.html. Select the Linux 64-bit version. Create a directory called 'terraform' and extract the .zip file into this directory.

1. On your VIRL server, generate an ssh key. You can do this using the command `ssh-keygen -t rsa`. Do NOT set a passphrase during key generation. Your public key is now available as .ssh/id_rsa.pub in /home/virl folder. 

2. register packet.net account

3. login to app.packet.net:
  1. add your ssh public rsa key (from /home/virl/.ssh/id_rsa.pub)
  2. create new project
  3. create api key token

4. On you VIRL server, go to /home/virl and then clone this repo using the command

   `git clone https://github.com/Snergster/virl_packet.git`

5. `cd virl_packet`

6. `cd keys`

7. copy your current salt keys into the keys directory as follows:

   `sudo cp /etc/salt/pki/minion/minion.pem .`

   `sudo cp /etc/salt/pki/minion/minion.pub .`

8. `cd ..`

9. `cp orig.variables.tf variables.tf`

10. get your project id using the command

   `curl -H 'X-Auth-Token:<putAPIkeyhere>' https://api.packet.net/projects`

    The command will return a set of output. Look for the field starting "id": Make a note of the UUID that follows that.

11. edit `variables.tf` and alter at the value in the 'default' fields for at least the following variables
  1. salt_id (xxxxxxxx.virl.info, the 'xxxxxxxx' is your salt_id)
  2. packet_api_key
  3. packet_project_id
  4. the various password (lets just stick with letters and numbers for now please)
	**Do NOT alter the salt_master value**

12. `../terraform/terraform plan .`       (to check for obvious errors)

13. `../terraform/terraform apply .`     (hopefully this will run without errors expect it to take 30 minutes)

14. `../terraform/terraform show`  (look for network.0.address )

15. login with ssh as `root@<network.0.address>`, or just go direct to `http://<network.0.address>` to login to your VIRL server webpage.
 
16. `../terraform/terraform destroy` to terminate the server instance

To start up again, repeat steps 14, 15, 16.
 
