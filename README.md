# ProjetLinuxAws

Projet linux dans AWS  

## Serveur à faire

* [x] SSH & Fail2ban
* [x] Samba & NFS global sans authentification -> Non
* [x] DNS principal
* [x] DNS client
* [x] Apache & Apache client
* [x] Samba client
* [x] FTP
* [x] FTP Client
* [x] Certificat SSL/TLS pour FTP
* [x] Certificat SSL/TLS pour https
* [x] MariaDB
* [x] MySqlSecure -> à vérif
* [ ] Monitoring -> à verif serv final
* [ ] NTP -> à vérif serv final
* [ ] Plan de sauvegarde
* [ ] FW
* [ ] **SELinux**
* [ ] Antivirus
* [ ] LVM

## Tuto installation

* git clone https://github.com/caimath/ProjetLinuxAws.git
* cd Scripts/
* sudo chmod +x SetupDependances.sh
* sudo ./SetupDependance.sh

* cd ../Client
* sudo chmod +x SetupClient.sh
* sudo ./SetupcClient.sh
