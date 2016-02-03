
#Steps:

0. install terraform.io to your local VIRL Server. This is available from https://www.terraform.io/downloads.html. Select the Linux 64-bit version. Create a directory called 'terraform' and extract the .zip file into this directory.

1. On your local VIRL server, generate an ssh key. You can do this using the command `ssh-keygen -t rsa`. Do NOT set a passphrase during key generation. Your public key is now available as .ssh/id_rsa.pub in /home/virl directory. 

2. register packet.net account

3. Log in to app.packet.net:
  1. Add your ssh public rsa key.  
  
     To get your public key from your local VIRL server, use the command

     `cat /home/virl/.ssh/id_rsa.pub`
     
     Paste the contents into the field on the Packet.net page.
     
  2. Create new project
  3. Create api key token

4. On your local VIRL server, go to /home/virl and then clone this repo using the command

   `git clone https://github.com/Snergster/virl_packet.git`

5. `cd virl_packet`

6. `cd keys`

7. copy your current salt keys into the keys directory and set the permissions, using the commands

   `sudo cp /etc/salt/pki/minion/minion.pem .`

   `sudo cp /etc/salt/pki/minion/minion.pub .`
   
   `sudo chmod 444 ./minion.pem`

8. `cd ..`

9. `cp variables.tf.orig variables.tf`

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

15. login to the remote VIRL server using ssh as `root@<network.0.address>`, or just go direct to `http://<network.0.address>` to login to your VIRL server webpage.

16. When logged in, to run commands such as 'nova service-list' you need to be operating as the virl user. To do this, use the command
 
    `su -l virl`

16. When you're ready to terminate your remote VIRL server instance, on your LOCAL VIRL server, issue the command 
 
    `../terraform/terraform destroy`

To start up again, repeat steps 14, 15, 16.

[NOTE] Your uwmadmin and guest passwords are in variables.tf. If you can't remember them, this is where you can find them.
 
