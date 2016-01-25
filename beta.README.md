
#Steps:

0. sudo salt-call state.sls virl.terraform  (this will install terraform, clone the repo, create ssh key, copy in minion keys and replace many variables in variables.tf)

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


10. get your project id using the command

   `curl -H 'X-Auth-Token:<putAPIkeyhere>' https://api.packet.net/projects`

    The command will return a set of output. Look for the field starting "id": Make a note of the UUID that follows that.

11. edit `variables.tf` and alter at the value in the 'default' fields for at least the following variables
  2. packet_api_key
  3. packet_project_id
	**Do NOT alter the salt_master value**

12. `terraform plan .`       (to check for obvious errors)

13. `terraform apply .`     (hopefully this will run without errors expect it to take 30 minutes)

14. `terraform show`  (output at the end should tell you everything you need)


16. When logged in, to run commands such as 'nova service-list' you need to be operating as the virl user. To do this, use the command
 
    `su -l virl`

16. When you're ready to terminate your remote VIRL server instance, on your LOCAL VIRL server, issue the command 
 
    `terraform destroy .`

To start up again, repeat steps 13.

[NOTE] Your uwmadmin and guest passwords are in variables.tf. If you can't remember them, this is where you can find them.
or by running terraform output
 
