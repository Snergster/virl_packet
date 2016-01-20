
#Steps:

0. install terraform.io

1. register packet.net account

2. login to app.packet.net:
  1. add your ssh key
  2. create new project
  3. create api key

3. clone this repo 

4. cd virl_packet

5. copy your current salt keys into the keys directory as minion.pem and minion.pub

6. cp orig.variables.tf variables.tf

7. get your project id  curl -H 'X-Auth-Token: putAPIkeyhere' https://api.packet.net/projects

8. edit variables.tf and alter at least
  1. packet_api_key
  2. packet_project_id
  3. the various password (lets just stick with letters and numbers for now please)

9. terraform plan .       (to check for obvious errors)

10. terraform apply .     (hopefully this will run without errors expect it to take 30 minutes)

11. terraform show  (look for network.0.address )

12. login with ssh as root, or just go direct to uwm to login/launch
