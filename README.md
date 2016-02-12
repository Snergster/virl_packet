THIS DOCUMENT IS FOR USERS WHO WANT TO RUN 'VIRL on PACKET' DIRECTLY FROM THEIR WORKSTATION/LAPTOP. YOU MUST HAVE A VALID VIRL LICENSE KEY. IF YOU WISH TO RUN 'VIRL on PACKET' FROM YOUR VIRL SERVER, PLEASE READ THE 'salt.README.md' FILE.

#Steps:

1. Install terraform.io for your operating system. This is available from https://www.terraform.io/downloads.html.  Extract the .zip file into a directory. You must make sure that the directory is then part of your 'path' environment, meaning that you can issue the command 'terraform' from the command line and it provides output. For instructions, please refer to https://www.terraform.io/intro/getting-started/install.html

WINDOWS USERS - Extract terraform to a directory under 'Program Files'.

WINDOWS USERS -  Go to Control panel -> System -> Advanced System settings* -> Environment Variables -> . Scroll down in system variables until you find PATH. Click 'edit' and change accordingly. BE SURE to include a semicolon at the end of the previous as that is the delimiter ie c:\path;c:\Program Files\terraform. You will need to launch a new command window for the settings to take effect.

2. Install a Git client of your choice then 'clone' the repo at `https://github.com/Snergster/virl_packet.git`.

3. Once the Git clone operation is complete, go into the directory called 'virl_packet' (or virl_packet.git).

4. You MAY need to generate an 'ssh key'. If you already have one, you can skip this step as long as you have NOT set a passphrase on the key. Depending on your operating system (Linux, Mac) you can do this using the command `ssh-keygen -t rsa`. Do NOT set a passphrase during key generation. To remove a passphrase from an existing key, use the command `ssh-keygen -p` and follow the prompts.

  WINDOWS USERS - popular SSH clients will have a function to be able to generate an ssh key. Please create an SSHv2 RSA key. Do NOT set a passphrase during key generation. The system requires the key to be compatible with OpenSSH. Some utilities provide a function to 'export' the key for use with OpenSSH. Place a copy of the PRIVATE KEY (id_rsa) and the PUBLIC KEY (id_rsa.pub) into the virl_packet directory. 

  LINUX AND MAC USER - set the permissions on the id_rsa.pub file using the command `chmod 755 id_rsa.pub`.

5. WINDOWS USERS - you must also install OpenSSL. This is available from `https://code.google.com/archive/p/openssl-for-windows/downloads`. Please install into a directory under 'Program Files' and add the 'openssl\bin' directory to your path. For example `"C:\Program Files\openssl\bin"`. See instructions at step 1 for details on how to modify your path.

6. register packet.net account
  1. Create api key token

7. Open a CLI window and go into the `virl_packet` directory and into the `keys` directory.

8. Copy the content of your VIRL license key (e.g. 'xxxxxxxx.virl.info.pem') into the 'keys' directory and name the file `minion.pem`. MAKE SURE THAT YOU INCLUDE THE HEADER AND FOOTER OF THE FILE. 

  LINUX AND MAC USERS - secure the .pem file using the command `sudo chmod 444 ./minion.pem`

9. You now need to generate a .pub key from your .pem file.

  issue the CLI command `openssl rsa -in minion.pem -pubout > minion.pub`.

10. Go back to the virl_packet directory level and make copies of the following files:

  LINUX AND MAC USERS - `cp variables.tf.orig variables.tf`, `cp passwords.tf.orig passwords.tf`, `cp settings.tf.orig settings.tf`.
 
  WINDOWS USERS - `copy variables.tf.orig variables.tf`, `copy passwords.tf.orig passwords.tf`, `copy settings.tf.orig settings.tf`.


11. Edit the files 
  1. `variables.tf` and alter salt_id so that it contains you VIRL license key file name (xxxxxxxx.virl.info, the 'xxxxxxxx' is your salt_id). 
   WINDOWS USERS - you must also change the 'ssh_private_key' default value so it reads "id_rsa".
  2. `password.tf` adjust these to suit your needs (stick to numbers and letters for now please)
  3. `settings.tf` - replace the packet_api `default` field with your packet_api_key. You can also adjust the 'dead_mans_timer' value and the 'packet_machine_type' that will be used with the VIRL server is created.

12. Run the command 

   `terraform plan .`
   
   This will validate the terraform .tf file.
   
13. Run the command 

   `terraform apply .`     
   
   This will spin up your Remote VIRL server and install the VIRL software stack. If this runs without errors, expect it to take ~30 minutes. When it completes, the system will report the IP address of your Remote VIRL server. Login using
   
    `ssh root@<ip address>` or `ssh virl@<ip address>`
    
    WINDOWS USERS - use you SSH client of choice in order to connect.
    
    NOTE - the VIRL server will reboot once the VIRL software has been installed. You must therefore wait until the reboot has completed before logging in.

14. To see more information about your Remote VIRL server, run the command 

   `terraform show` 
   
   The output will provided details of your Remote VIRL server instance.


15. If logged in as `root`, to run commands such as 'nova service-list' you need to be operating as the virl user. To do this, use the command
 
    `su -l virl`

16. The VIRL server is provisioned in a secure manner. To access the server, you must establish an OpenVPN tunnel to the server.
    1. Install an OpenVPN client for your system.
    2. The set up of the remote VIRL server will automatically configure the OpenVPN server. The 'client.ovpn' connection profile will be automatically downloaded to the directory from which you ran the `terraform apply .` command. 
    3. The 'client.ovpn' file can be copied out to other devices, such as a laptop hosting your local VIRL instance.
    4. Download the file and open it with your OpenVPN client
   
    NOTE - the VIRL server will reboot once the VIRL software has been installed. You must therefore wait until the reboot has completed before bringing up the OpenVPN tunnel.
    
17. With your OpenVPN tunnel up, the VIRL server is available at http://172.16.11.254.
    If using VM Maestro, you must set up the connection profile to point to `172.16.11.254`

18. When you're ready to terminate your remote VIRL server instance, on your LOCAL VIRL server, issue the command 
 
    `terraform destroy .`

19. Log in to the Packet.net portal
   1. Review the 'Manage' tab to confirm that the server instance has indeed been deleted and if necessary, delete the server
   2. Review the 'SSH Keys' tab and remove any ssh keys that are registered

To start up again, repeat step 12.

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

 
