THIS DOCUMENT IS FOR USERS WHO WANT TO RUN 'VIRL on PACKET' DIRECTLY FROM THEIR WORKSTATION/LAPTOP. IF YOU WISH TO RUN 'VIRL on PACKET' FROM YOUR VIRL SERVER, PLEASE READ THE 'salt.README.md' FILE.

#Steps:

1. Install terraform.io for your operating system. This is available from https://www.terraform.io/downloads.html.  Extract the .zip file into a directory. You must make sure that the directory is then part of your 'path' environment, meaning that you can issue the command 'terraform' from the command line and it provides output. For instructions, please refer to https://www.terraform.io/intro/getting-started/install.html

  WINDOWS USERS -  Go to Control panel -> System -> Advanced System settings* -> Environment Variables -> . Scroll down in system variables until you find PATH. Click 'edit' and change accordingly. BE SURE to include a semicolon at the end of the previous as that is the delimiter ie c:\path;c:\path2. You will need to launch a new command window for the settings to take effect.

2. Install a Git client of your choice then 'clone' the repo at `https://github.com/Snergster/virl_packet.git`.

3. Once the Git clone operation is complete, go into the directory called 'virl_packet' (or virl_packet.git).

4. You need to generate an 'ssh key'. Depending on your operating system (Linux, Mac) you can do this using the command `ssh-keygen -t rsa`. Do NOT set a passphrase during key generation. 

  WINDOWS USERS - popular SSH clients will have a function to be able to generate an ssh key. Please create an SSHv2 RSA key. Do NOT set a passphrase during key generation. The system requires the key to be compatible with OpenSSH. Some utilities provide a function to 'export' the key for use with OpenSSH. Place a copy of the PRIVATE KEY (id_rsa) and the PUBLIC KEY (id_rsa.pub) into the virl_packet directory. 

  LINUX AND MAC USER - set the permissions on the id_rsa.pub file using the command `chmod 755 id_rsa.pub`.

5. WINDOWS USERS - you must also install OpenSSL. This is available from `https://code.google.com/archive/p/openssl-for-windows/downloads`. Please install and add the 'bin' directory to your path. For example `"C:\Program Files (x86)\openssl\bin"`. See instructions at step 1 for details on how to modify your path.

6. register packet.net account
  1. Create api key token

7. Open a CLI window and go into the `virl_packet` directory and into the `keys` directory.

8. Copy the content of your VIRL license key (e.g. 'xxxxxxxx.virl.info.pem') into the 'keys' directory and name the file `minion.pem`. MAKE SURE THAT YOU INCLUDE THE HEADER AND FOOTER OF THE FILE. 

  LINUX AND MAC USERS - secure the .pem file using the command `sudo chmod 444 ./minion.pem`

9. You now need to generate a .pub key from your .pem file.

  issue the CLI command `openssl rsa -in minion.pem -pubout >> minion.pub`.

10. Go back to the virl_packet directory level and make copies of the following files:

  LINUX AND MAC USERS - `cp variables.tf.orig variables.tf`, `cp passwords.tf.org passwords.tf`, `cp settings.tf.orig settings.tf`.
 
  WINDOWS USERS - `copy variables.tf.orig variables.tf`, `copy passwords.tf.org passwords.tf`, `copy settings.tf.orig settings.tf`.


11. Edit the files 
  1. `variables.tf` and alter salt_id so that it contains you VIRL license key file name (xxxxxxxx.virl.info, the 'xxxxxxxx' is your salt_id). WINDOWS USERS - you must also change the 'ssh_private_key' default value so it reads "id_rsa".
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
    
17. With your OpenVPN tunnel up, the VIRL server is available at http://172.16.1.254.
    If using VM Maestro, you must set up the connection profile to point to `172.16.1.254`

18. When you're ready to terminate your remote VIRL server instance, on your LOCAL VIRL server, issue the command 
 
    `terraform destroy .`

To start up again, repeat step 12.

[NOTE] Your uwmadmin and guest passwords are in passwords.tf. If you can't remember them, this is where you can find them, or by running terraform output
 
