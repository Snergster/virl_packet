
Steps:
1. register packet.net account
2. login to app.packet.net:
  a. add your ssh key
  b. create new project
  c. create api key
3. clone this repo 
4. cd virl_packet
5. copy your current salt keys into the keys directory as minion.pem and minion.pub
5. cp orig.variables.tf variables.tf
6. get your project id  curl -H 'X-Auth-Token: putAPIkeyhere' https://api.packet.net/projects
7. edit variables.tf and alter at least
  a. packet_api_key
  b. packet_project_id
  c. the various password (lets just stick with letters and numbers for now please)

