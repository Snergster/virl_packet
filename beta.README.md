
#Steps:

1. On your local VIRL server, run the command

   `sudo salt-call -l debug state.sls virl.terraform`
   
   This will install terraform, clone the repo, create an ssh key, copy in minion keys and replace many variables in the variables.tf file.
   
2. Register with www.packet.net for an account

3. Log in to app.packet.net:
  3. Create api key token

4. `cd virl_packet`

6. edit `variables.tf` and alter at the value in the 'default' fields for at least the following variables
  1. packet_api_key
	**Do NOT alter the salt_master value**

7. Run the command 

   `terraform plan .`
   
   This will validate the terraform .tf file.
   
8. Run the command 

   `terraform apply .`     
   
   This will spin up your Remote VIRL server and install the VIRL software stack. If this runs without errors, expect it to take ~30 minutes. When it completes, the system will report the IP address of your Remote VIRL server. Login using
   
    `ssh root@<ip address>` or `ssh virl@<ip address>`

9. To see more information about your Remote VIRL server, run the command 

   `terraform show` 
   
   The output will provided details of your Remote VIRL server instance.


10. If logged in as `root`, to run commands such as 'nova service-list' you need to be operating as the virl user. To do this, use the command
 
    `su -l virl`

11. The VIRL server is provisioned in a secure manner. To access the server, you must establish an OpenVPN tunnel to the server.
    1. Install an OpenVPN client for your system.
    2. The set up of the remote VIRL server will automatically configure the OpenVPN server. The 'client.ovpn' connection profile will be automatically downloaded to the directory from which you ran the `terraform apply .` command. 
    3. The 'client.ovpn' file can be copied out to other devices, such as a laptop hosting your local VIRL instance.
    4. Download the file and open it with your OpenVPN client
    
12. With your OpenVPN tunnel up, the VIRL server is available at http://172.16.1.254  

13. When you're ready to terminate your remote VIRL server instance, on your LOCAL VIRL server, issue the command 
 
    `terraform destroy .`

To start up again, repeat step 7.

[NOTE] Your uwmadmin and guest passwords are in variables.tf. If you can't remember them, this is where you can find them, or by running terraform output
 
