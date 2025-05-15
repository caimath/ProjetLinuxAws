# ProjetLinuxAws

Projet linux dans AWS  

## Serveur à faire

* [x] SSH & Fail2ban
* [x] Samba & NFS global sans authentification
* [x] DNS principal + DNS Externe
* [x] DNS client
* [x] Apache & Apache client
* [x] Samba client
* [x] FTP
* [x] FTP Client
* [x] Certificat SSL/TLS pour FTP
* [x] Certificat SSL/TLS pour https
* [x] MariaDB
* [x] MySqlSecure
* [x] Monitoring
* [x] NTP -> à vérif serv final
* [ ] Plan de sauvegarde
* [x] FW -> on va dire
* [x] SELinux
* [ ] Antivirus
* [ ] LVM

## Tuto installation

### Serveur Linux

* git clone https://github.com/caimath/ProjetLinuxAws.git
* cd Scripts/
* sudo chmod +x SetupDependances.sh
* sudo ./SetupDependance.sh

* cd ../Client
* sudo chmod +x SetupClient.sh
* sudo ./SetupcClient.sh

### Client Windows

* Changer DNS dans ncpa.cpl pour carte réseau openVPN
