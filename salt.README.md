THIS DOCUMENT IS FOR USERS WHO WANT TO RUN 'VIRL on PACKET' FROM THEIR VIRL SERVER. IF YOU WISH TO RUN 'VIRL on PACKET' FROM YOUR WORKSTATION/LAPTOP, PLEASE READ THE 'README.md' FILE.

#Steps:

1. On your local VIRL server, run the commands

   `sudo vinstall salt`
   
   `sudo salt-call state.sls virl.terraform`
   
   This will install terraform, clone the repo, create an ssh key, copy in minion keys and replace many variables in the variables.tf file.
   
2. Register with www.packet.net for an account

3. Log in to app.packet.net:
  3. Create api key token

4. `cd virl_packet`

5. edit `passwords.tf` Note: The salt state (virl.terraform) will generate new passwords for you. You adjust these to suit your needs but please stick to numbers and letters as the characters in the password. If the salt state is run again, new passwords will be generated, overwriting any values you have applied. 

6. Edit `settings.tf`. Replace the packet_api `default` field with your packet_api_key. You can also adjust the 'dead_mans_timer' value and the 'packet_machine_type' that will be used with the VIRL server is created.

7. Run the command 

   `terraform plan .`
   
   This will validate the terraform .tf file.
   
8. Run the command 

   `terraform apply .`     
   
   This will spin up your Remote VIRL server and install the VIRL software stack. If this runs without errors, expect it to take ~30 minutes. When it completes, the system will report the IP address of your Remote VIRL server. Login using
   
    `ssh root@<ip address>` or `ssh virl@<ip address>`
    
    NOTE - the VIRL server will reboot once the VIRL software has been installed. You must therefore wait until the reboot has completed before logging in.

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
   
    NOTE - the VIRL server will reboot once the VIRL software has been installed. You must therefore wait until the reboot has completed before bringing up the OpenVPN tunnel.
    
12. With your OpenVPN tunnel up, the VIRL server is available at http://172.16.11.254.
    If using VM Maestro, you must set up the connection profile to point to `172.16.11.254`

13. When you're ready to terminate your remote VIRL server instance, on your LOCAL VIRL server, issue the command 
 
    `terraform destroy .`

14. Log in to the Packet.net portal
   1. Review the 'Manage' tab to confirm that the server instance has indeed been deleted and if necessary, delete the server
   2. Review the 'SSH Keys' tab and remove any ssh keys that are registered

To start up again, repeat step 7.

[NOTE] Your uwmadmin and guest passwords are in passwords.tf. If you can't remember them, this is where you can find them, or by running the command `terraform show`.

# If your VIRL server bring-up fails to complete successfully:

1. Terminate the instance using the command:

   `terraform destroy .`

2. Log in to the Packet.net portal
   1. Review the 'Manage' tab to confirm that the server instance has indeed been deleted and if necessary, delete the server.
   2. Review the 'SSH Keys' tab and remove any ssh keys that are registered
    
   [NOTE] a server can only be terminated on the Packet.net portal once the server's status is reported as 'green'. You may therefore need to wait for a few minutes in order for the server to reach this state.

# Dead man's timer:

When a VIRL server is initialised, a 'dead man's timer' value is set. The purpose of the timer is to avoid a server instance being left running on the platform for an indefinite period. 

The timer value is set by default to four (4) hours and can be changed by modifying the 'dead mans timer' value in the settings.tf file before you start your server instance. The value you set will be applied each time you start up a server instance until you next modify the value.

If your server is running at the point where the timer expires, your server instance will be terminated automatically. Any information held on the server will be lost.

You are able to see when the timer will expire by logging in (via ssh) to the server instance and issuing the command `sudo atq`. You can remove the timer, leaving the server to run indefinitely, by issuing the command `sudo atrm 1`.
