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
* [] SELinux -> Fonctionne pas
* [x] Antivirus
* [ ] LVM

## Tuto installation

### Serveur Linux

* sudo dnf install git
* git clone https://github.com/caimath/ProjetLinuxAws.git
* sudo chmod +x installAll.sh
* sudo ./installAll.sh

### Client Windows

* Changer DNS dans ncpa.cpl pour carte réseau openVPN

## Tester

### Windows client

* FTP avec certif
* Samba share et /var/www
* Apache avec certif et apache utilisateur
* phpmyadmin, se log
* DNS internet avec nslookup
* netdata: ip:1999

### Linux Serveur

* NTP -> date
* DNS externe -> dig google.com @ip , lancer 2x pour voir rapidité cache
* AV tester automatiquement si pas -> sudo clamscan --log=/var/log/clamav/scan.log /var/www /etc
* NFS: showmount -e ip -> Renvoie share
* Fail2ban -> sudo fail2ban-client status et voir détail: sudo fail2ban-client status sshd et journal: sudo journalctl -u fail2ban
* Firewall:
  * sudo systemctl status firewalld
  * sudo firewall-cmd --list-all
  * sudo firewall-cmd --list-all-zones
  * sudo firewall-cmd --query-port=19999/tcp
