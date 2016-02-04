
#Steps:

0. install terraform.io. This is available from https://www.terraform.io/downloads.html.  Extract the .zip file into this directory and install files in a directory in your path.

1. Install git client if you dont have one and clone this repo.  `git clone https://github.com/Snergster/virl_packet.git`

2. cd virl_packet

3. Install ssh if not already, generate an ssh key. You can do this using the command `ssh-keygen -t rsa`. Do NOT set a passphrase during key generation. Place keys in your virl_packet directory. chmod 755 id_rsa

4. register packet.net account

5. Log in to app.packet.net:
  1. Add your ssh public rsa key.  
  
     `cat id_rsa.pub`
     
     Paste the contents into the field on the app.packet.net page.
     
  3. Create api key token

6. `cd keys`

7. copy your current salt keys into the keys directory and set the permissions if necessary you should have

   `minion.pem`

   `minion.pub`
   
   `sudo chmod 444 ./minion.pem`

8. `cd ..`

9. `cp variables.tf.orig variables.tf`, `cp passwords.tf.org passwords.tf`, `cp api.tf.orig api.tf`


11. edit variable files 
  1. `variables.tf` and alter salt_id (xxxxxxxx.virl.info, the 'xxxxxxxx' is your salt_id)
  2. `api.tf` and alter packet_api_key
  3. `password.tf` the various password (lets just stick with letters and numbers for now please)

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
 
