#!/bin/bash

clear

RED='\033[0;31m' 
BLUE='\e[38;5;33m' 
NC='\033[0m' 

updatedb
systemctl enable --now cockpit.socket
firewall-cmd --permanent --zone=public --add-service=cockpit
firewall-cmd --reload
dnf -y install nfs-utils samba bind chrony fail2ban vsftpd rsync clamav clamd clamav-update bind-utils httpd php php-mysqlnd mariadb-server phpmyadmin mod_ssl

clear

display_menu() {
    echo ""
    echo "|----------------------------------------------------------------------|"
    echo -e "|                 ${BLUE}Welcome to the server assistant ${NC}                     |"
    echo "|              Please select the tool you want to use                  |"
    echo "|----------------------------------------------------------------------|"
    echo "| 0. Set server hostname                                               |"
    echo "| 1. RAID Configuration                                                |"
    echo "| 2. SSH Connection                                                    |"
    echo "| 3. NFS/SAMBA Shared Directory (no auth)                              |"
    echo "| 4. Web services management                                           |"
    echo "| 5. NTP Time Server                                                   |"
    echo "| 6. Install clamav                                                    |"
    echo "| 7. Backup                                                            |"
    echo "| 8. Consult Logs Dashboard                                            |"
    echo "|----------------------------------------------------------------------|"
    echo "| q. Quit                                                              |"
    echo "|----------------------------------------------------------------------|"
    echo ""
}

display_hostname_menu() {
    echo ""
    echo "|----------------------------------------------------------------------|"
    echo -e "|                     ${BLUE}Hostname Configuration Menu ${NC}                     |"
    echo "|----------------------------------------------------------------------|"
    echo "| 1. Set hostname                                                      |"
    echo "| 2. Display current hostname                                          |"
    echo "|----------------------------------------------------------------------|"
    echo "| q. Quit                                                              |"
    echo "|----------------------------------------------------------------------|"
    echo ""
}

display_raid_menu() {
    echo ""
    echo "|----------------------------------------------------------------------|"
    echo -e "|                 ${BLUE}RAID Configuration Menu ${NC}                     |"
    echo "|----------------------------------------------------------------------|"
    echo "| 1. Create RAID                                                       |"
    echo "| 2. Display current RAID                                              |"
    echo "|----------------------------------------------------------------------|"
    echo "| q. Quit                                                              |"
    echo "|----------------------------------------------------------------------|"
    echo ""
}

display_unauth_share_menu() {
    echo ""
    echo "|----------------------------------------------------------------------|"
    echo -e "|                ${BLUE}Welcome to the unauth share assistant ${NC}                |"
    echo "|              Please select the tool you want to use                  |"
    echo "|----------------------------------------------------------------------|"
    echo "| 0. Activate NFS                                                      |"
    echo "| 1. Activate SMB                                                      |"
    echo "|----------------------------------------------------------------------|"
    echo "| q. Quit                                                              |"
    echo "|----------------------------------------------------------------------|"
    echo ""
}

display_web_menu() {
    echo ""
    echo "|----------------------------------------------------------------------|"
    echo -e "|                ${BLUE}Welcome To The User Management Menu ${NC}                  |"
    echo "|               Please select the tool you want to use                 |"
    echo "|----------------------------------------------------------------------|"
    echo "| 0. Basic setup (main DNS, web, DB, mail)                             |"
    echo "| 1. Add User                                                          |"
    echo "| 2. Remove User                                                       |"
    echo "|----------------------------------------------------------------------|"
    echo "| q. Quit                                                              |"
    echo "|----------------------------------------------------------------------|"
    echo ""
}

display_ntp_menu() {
    echo "|-------------------------------------------|"
    echo -e "|            ${GREEN}NTP server wizard${NC}              |"
    echo "|-------------------------------------------|"
    echo "|         What do you want to do?           |"
    echo "|-------------------------------------------|"
    echo "| 1. Setup the NTP (defaults to Eu/Bx)      |"
    echo "| 2. Choose a timezone                      |"
    echo "| 3. Show NTP statuses                      |"
    echo "|-------------------------------------------|"
    echo "| q. Quit                                   |"
    echo "|-------------------------------------------|"
    echo ""
}

set_hostname() {
while true; do

    clear
    display_hostname_menu
    read -p "Enter your choice: " hostname_choice
    case $hostname_choice in
        1) read -p "Enter the new hostname: " new_hostname
           hostnamectl set-hostname $new_hostname
           echo "Hostname set to $new_hostname"
           echo "Press any key to continue..."
           read -n 1 -s key
           clear
           ;;
        2) current_hostname=$(hostnamectl --static)
           echo "Current hostname: $current_hostname"
               echo "Press any key to continue..."
               read -n 1 -s key
               clear
           ;;
        q|Q) clear && echo "Exiting hostname configuration menu" && break ;;
        *) clear && echo "Invalid choice. Please enter a valid option." ;;
    esac
done
}

raid(){
    clear
    echo "Creating RAID..."
    sudo dnf install lvm2 mdadm -y
    sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd
    sudo pvcreate /dev/md0
    sudo vgcreate vg_raid5 /dev/md0
    sudo lvcreate -L 500M -n share vg_raid5
    sudo mkfs.ext4 /dev/vg_raid5/share
    sudo mkdir -p /mnt/raid5_share
    sudo mount /dev/vg_raid5/share /mnt/raid5_share
    sudo blkid /dev/vg_raid5/share | awk '{print $2 " /mnt/raid5_share ext4 defaults 0 0"}' | sudo tee -a /etc/fstab
    sudo lvcreate -L 500M -n web vg_raid5
    sudo mkfs.ext4 /dev/vg_raid5/web
    sudo mkdir -p /mnt/raid5_web
    sudo mount /dev/vg_raid5/web /mnt/raid5_web
    sudo blkid /dev/vg_raid5/web | awk '{print $2 " /mnt/raid5_web ext4 defaults 0 0"}' | sudo tee -a /etc/fstab
    systemctl daemon-reload
    df -h
}

ssh(){
    clear
    echo "Starting ssh"
    sudo systemctl enable --now sshd
    sudo systemctl start sshd
    sudo firewall-cmd --permanent --add-service=ssh
    sudo firewall-cmd --reload

    # Generate SSH key pair
    ssh-keygen -t rsa -b 4096

    # Copy public key to authorized_keys file
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

    # Set permissions for SSH files
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub
    chmod 644 ~/.ssh/authorized_keys

    # Restart SSH service
    sudo systemctl restart sshd
}

unauthshare(){
    smb(){
    echo "Installing Samba share"
    sudo mkdir -p /mnt/raid5_share

    # Set quota on /mnt/raid5_share
    quotacheck -cug /mnt/raid5_share
    quotaon /mnt/raid5_share
    edquota -u nobody -f /mnt/raid5_share -s 500M -h 600M
    dnf update -y
    dnf -y install samba samba-client
    systemctl enable smb --now
    systemctl enable nmb --now    

    firewall-cmd --permanent --add-service=samba
    firewall-cmd --reload

    chown -R nobody:nobody /mnt/raid5_share
    chmod -R 0777 /mnt/raid5_share
    
    cat <<EOL > /etc/samba/smb.unauth.conf
[unauth_share]
   path = /mnt/raid5_share/
   browsable = yes
   writable = yes
   guest ok = yes
   guest only = yes
   force user = nobody
   force group = nobody
   create mask = 0777
   directory mask = 0777
   read only = no
EOL
    
    PRIMARY_CONF="/etc/samba/smb.conf"
    INCLUDE_LINE="include = /etc/samba/smb.unauth.conf"

    if ! grep -Fxq "$INCLUDE_LINE" "$PRIMARY_CONF"; then
        echo "$INCLUDE_LINE" >> "$PRIMARY_CONF"
        echo "Include line added to $PRIMARY_CONF"
    else
        echo "Include line already exists in $PRIMARY_CONF"
    fi

    # SELINUX RAHHHHHHHHHHH
    /sbin/restorecon -R -v /mnt/raid5_share
    setsebool -P samba_export_all_rw 1

    systemctl restart smb
    systemctl restart nmb

    echo "Samba services restarted"

    echo "Press any key to continue..."
    read -n 1 -s key
	clear
}

nfs(){
    echo "Installing NFS share"
    sudo mkdir -p /mnt/raid5_share
    dnf update -y
    dnf -y install nfs-utils
    systemctl enable nfs-server --now
    firewall-cmd --permanent --add-service=nfs
    firewall-cmd --permanent --add-service=mountd
    firewall-cmd --permanent --add-service=rpc-bind
    firewall-cmd --reload
    echo "/mnt/raid5_share *(rw,sync,no_root_squash)" > /etc/exports
    exportfs -a
    systemctl restart nfs-server
    echo "NFS services restarted"
    echo "Press any key to continue..."
    read -n 1 -s key
    clear
}

    clear
    echo "Starting unauthshare"
    while true; do
        display_unauth_share_menu
        read -p "Enter your choice: " choice
        case $choice in
            0) nfs ;;
            1) smb ;;
            q|Q) clear && echo "Exiting the web server configuration wizard." && break ;;
            *) clear && echo "Invalid choice. Please enter a valid option." ;;
        esac
    done

}

webservices(){
    backup_file(){
    ORIGINAL_FILE=$1
    if [ ! -f "$ORIGINAL_FILE" ]; then
        echo "Error: $ORIGINAL_FILE does not exist."
        exit 1
    fi
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    BACKUP_FILE="/etc/named.conf.bak.$TIMESTAMP"
    mv "$ORIGINAL_FILE" "$BACKUP_FILE"
    touch "$ORIGINAL_FILE"
    if [ $? -eq 0 ]; then
        echo "Successfully backed up $ORIGINAL_FILE to $BACKUP_FILE"
    else
        echo "Error: Failed to back up $ORIGINAL_FILE"
        exit 1
    fi
}

basic_dns(){
    firewall-cmd --add-service=dns --permanent
    firewall-cmd --reload
    IP_ADDRESS=$1
    DOMAIN_NAME=$2
    NETWORK=$(echo $IP_ADDRESS | cut -d"." -f1-3).0/24
    REVERSE_ZONE=$(echo $IP_ADDRESS | awk -F. '{print $3"."$2"."$1".in-addr.arpa"}')
    REVERSE_IP=$(echo $IP_ADDRESS | awk -F. '{print $4}')
    backup_file "/etc/named.conf"
    dnf -y install bind bind-utils

cat <<EOL > /etc/named.conf
options {
    listen-on port 53 { any; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    secroots-file   "/var/named/data/named.secroots";
    recursing-file  "/var/named/data/named.recursing";
    allow-query { any; };
    recursion yes;
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

zone "$DOMAIN_NAME" IN {
    type master;
    file "forward.$DOMAIN_NAME";
    allow-update { none; };
};

zone "$REVERSE_ZONE" IN {
    type master;
    file "reverse.$DOMAIN_NAME";
    allow-update { none; };
};
EOL

cat <<EOL > /var/named/forward.$DOMAIN_NAME
\$TTL 86400
@   IN  SOA     ns.$DOMAIN_NAME. root.$DOMAIN_NAME. (
            2024052101 ; Serial
            3600       ; Refresh
            1800       ; Retry
            604800     ; Expire
            86400 )    ; Minimum TTL
;
@       IN  NS      ns.$DOMAIN_NAME.
ns      IN  A       $IP_ADDRESS
@       IN  A       $IP_ADDRESS
*       IN  A       $IP_ADDRESS
mail    IN  A       $IP_ADDRESS
EOL

cat <<EOL > /var/named/reverse.$DOMAIN_NAME
\$TTL 86400
@   IN  SOA     ns.$DOMAIN_NAME. root.$DOMAIN_NAME. (
            2024052101 ; Serial
            3600       ; Refresh
            1800       ; Retry
            604800     ; Expire
            86400 )    ; Minimum TTL
;
@       IN  NS      ns.$DOMAIN_NAME.
$REVERSE_IP       IN  PTR     $DOMAIN_NAME.
EOL

echo 'OPTIONS="-4"' >> /etc/sysconfig/named

cat <<EOL > /etc/hosts
$IP_ADDRESS $DOMAIN_NAME
127.0.0.1   $DOMAIN_NAME
EOL

cat <<EOL > /etc/hostname
$DOMAIN_NAME
EOL

    systemctl start named
    systemctl enable named

    systemctl restart named 

cat <<EOL > /etc/resolv.conf
nameserver  $DOMAIN_NAME
options edns0 trust-ad
search home.arpa
EOL
}

basic_root_website(){
    DOMAIN_NAME=$1
    dnf -y install httpd mod_ssl
    mkdir -p /mnt/raid5_web/root
    echo "<html><body><h1>Welcome to $DOMAIN_NAME</h1></body></html>" > /mnt/raid5_web/root/index.php
    chown -R apache:apache /mnt/raid5_web/root
    chcon -R --type=httpd_sys_content_t /mnt/raid5_web/root
    chmod -R 755 /mnt/raid5_web/root
    cat <<EOL > /etc/httpd/conf.d/root.conf
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    ServerAlias *.$DOMAIN_NAME
    DocumentRoot /mnt/raid5_web/root
    <Directory /mnt/raid5_web/root>
        AllowOverride All
        Require all granted
    </Directory>
    DirectoryIndex index.php
    ErrorLog /var/log/httpd/root_error.log
    CustomLog /var/log/httpd/root_access.log combined

    # Redirect all traffic to HTTPS
    Redirect "/" "https://$DOMAIN_NAME/"
</VirtualHost>
EOL

    # Generate a wildcard self-signed SSL certificate
    mkdir -p /etc/httpd/ssl
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -keyout /etc/httpd/ssl/$DOMAIN_NAME.key \
        -out /etc/httpd/ssl/$DOMAIN_NAME.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=*.$DOMAIN_NAME"

    # Set up the virtual host for HTTPS
    cat <<EOL > /etc/httpd/conf.d/root-ssl.conf
<VirtualHost *:443>
    ServerName $DOMAIN_NAME
    ServerAlias *.$DOMAIN_NAME
    DocumentRoot /mnt/raid5_web/root
    <Directory /mnt/raid5_web/root>
        AllowOverride All
        Require all granted
    </Directory>
    DirectoryIndex index.php
    SSLEngine on
    SSLCertificateFile /etc/httpd/ssl/$DOMAIN_NAME.crt
    SSLCertificateKeyFile /etc/httpd/ssl/$DOMAIN_NAME.key
    ErrorLog /var/log/httpd/root_ssl_error.log
    CustomLog /var/log/httpd/root_ssl_access.log combined
</VirtualHost>
EOL

    # Start and enable the Apache HTTP server
    systemctl start httpd
    systemctl enable httpd
    systemctl restart httpd
    firewall-cmd --add-service=http --permanent
    firewall-cmd --add-service=https --permanent
    firewall-cmd --reload
    echo "Verifying HTTP Access..."
    curl -I http://$DOMAIN_NAME
    echo "Verifying HTTPS Access..."
    curl -I https://$DOMAIN_NAME
}

basic_db(){
    DOMAIN_NAME=$1
    dnf -y install mariadb-server phpmyadmin
    systemctl start mariadb
    systemctl enable mariadb
    mysql_secure_installation <<EOF

y
rootpassword
rootpassword
y
y
y
y
EOF

    firewall-cmd --add-service=mysql --permanent
    firewall-cmd --reload
    ln -s /usr/share/phpmyadmin /mnt/raid5_web/root/phpmyadmin
    conf_file="/etc/httpd/conf.d/phpMyAdmin.conf"

cat <<EOL > $conf_file
# phpMyAdmin - Web based MySQL browser written in php
# 
# Allows only localhost by default
#
# But allowing phpMyAdmin to anyone other than localhost should be considered
# dangerous unless properly secured by SSL

Alias /phpmyadmin /usr/share/phpMyAdmin

<Directory /usr/share/phpMyAdmin/>
    AddDefaultCharset UTF-8

    Require all granted
</Directory>

<Directory /usr/share/phpMyAdmin/setup/>
   Require local
</Directory>

# These directories do not require access over HTTP - taken from the original
# phpMyAdmin upstream tarball
#
<Directory /usr/share/phpMyAdmin/libraries/>
    Require all denied
</Directory>

<Directory /usr/share/phpMyAdmin/templates/>
    Require all denied
</Directory>

<Directory /usr/share/phpMyAdmin/setup/lib/>
    Require all denied
</Directory>

<Directory /usr/share/phpMyAdmin/setup/frames/>
    Require all denied
</Directory>

# This configuration prevents mod_security at phpMyAdmin directories from
# filtering SQL etc.  This may break your mod_security implementation.
#
#<IfModule mod_security.c>
#    <Directory /usr/share/phpMyAdmin/>
#        SecRuleInheritance Off
#    </Directory>
#</IfModule>
EOL

    systemctl restart httpd
    echo "Configuration updated and Apache restarted."
    ausearch -c 'mariadbd' --raw | audit2allow -M my-mariadbd
    semodule -X 300 -i my-mariadbd.pp
    echo "<html><body><h1>PHPMyAdmin installed. <a href='/phpmyadmin'>Access it here</a></h1></body></html>" > /mnt/raid5_web/root/index.php
    systemctl restart httpd
}

basic_mail(){
    sudo dnf -y install postfix dovecot roundcubemail
    DOMAIN_NAME=$1

    echo "meow"

    configure_postfix(){
    DOMAIN_NAME=$1

    postconf -e "myhostname = mail.$DOMAIN_NAME"
    postconf -e "mydomain = $DOMAIN_NAME"
    postconf -e "myorigin = /etc/mailname"
    postconf -e "inet_interfaces = all"
    postconf -e "inet_protocols = all"
    postconf -e "mydestination = $DOMAIN_NAME, localhost.localdomain, localhost"
    postconf -e "relayhost ="
    postconf -e "mynetworks = 127.0.0.0/8"
    postconf -e "mailbox_size_limit = 0"
    postconf -e "recipient_delimiter = +"
    postconf -e "inet_interfaces = all"
    postconf -e "inet_protocols = ipv4"

    # Add domain to /etc/mailname
    echo "$DOMAIN_NAME" > /etc/mailname

    # Restart Postfix
    systemctl restart postfix
    systemctl enable postfix

    echo "Postfix configured for domain $DOMAIN_NAME."
    echo "Press any key to exit..."
    read -n 1 -s key
}

configure_dovecot(){
    DOMAIN_NAME=$1

    # Backup the original config files
    cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak
    if [ ! -f "/etc/dovecot/dovecot.conf" ]; then
        touch /etc/dovecot/dovecot.conf
    fi
    cp /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.bak
    if [ ! -f "/etc/dovecot/conf.d/10-mail.conf" ]; then
        touch /etc/dovecot/conf.d/10-mail.conf
    fi
    # Configure Dovecot
    cat <<EOL > /etc/dovecot/dovecot.conf
disable_plaintext_auth = yes
mail_privileged_group = mail
mail_location = maildir:~/Maildir
namespace inbox {
  inbox = yes
}
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
userdb {
  driver = passwd
}
passdb {
  driver = pam
}
ssl = required
ssl_cert = </etc/pki/dovecot/certs/dovecot.pem
ssl_key = </etc/pki/dovecot/private/dovecot.pem
EOL

    # Restart Dovecot
    systemctl restart dovecot
    systemctl enable dovecot

    echo "Dovecot configured for domain $DOMAIN_NAME."
    echo "Press any key to exit..."
    read -n 1 -s key
}


configure_roundcube(){
    DB_PASSWORD=$(openssl rand -base64 12)
    DOMAIN_NAME=$1

    # Create a database for Roundcube
    mysql -u root -p<<MYSQL_SCRIPT
    CREATE DATABASE roundcube_db;
    GRANT ALL PRIVILEGES ON roundcube_db.* TO 'roundcube'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT

    # Generate the Roundcube config file
    cat <<EOL > /etc/roundcubemail/config.inc.php
<?php
\$config['db_dsnw'] = 'mysql://roundcube:$DB_PASSWORD@127.0.0.1/roundcube_db';
\$config['default_host'] = '127.0.0.1';
\$config['smtp_server'] = '127.0.0.1';
\$config['mail_domain'] = '$DOMAIN_NAME';
\$config['product_name'] = 'Caca Mail';
\$config['des_key'] = '$(openssl rand -base64 24)';
\$config['plugins'] = [];
\$config['enable_spellcheck'] = true;
?>
EOL

    # Apply SELinux and restart Apache
    setsebool -P httpd_can_sendmail 1
    systemctl restart httpd

    echo "Roundcube configured with the domain $DOMAIN_NAME."
    echo "Press any key to exit..."
    read -n 1 -s key
}

    DOMAIN_NAME=$1

    echo "Setting up the mail server for domain $DOMAIN_NAME..."

    configure_postfix $DOMAIN_NAME
    configure_dovecot $DOMAIN_NAME
    configure_roundcube $DOMAIN_NAME

    echo "Mail server setup completed."
    echo "Press any key to exit..."
    read -n 1 -s key
}

basic_setup(){
    echo "Installing required components"
    read -p "Enter the IP address : " IP_ADDRESS
    read -p "Enter the server domain name (e.g., test.toto) : " DOMAIN_NAME
    basic_dns $IP_ADDRESS $DOMAIN_NAME
    echo "Main DNS configuration done ... "

    basic_root_website $DOMAIN_NAME
    echo "Web server configuration done ... "

    basic_db $DOMAIN_NAME
    echo "Database server configuration done ... "

    basic_mail $DOMAIN_NAME
    echo "Mail server configuration done ... "

    echo "Press any key to exit..."
    read -n 1 -s key
    clear
}

add_user(){
    echo "Adding a user ..."
    read -p "Enter the server domain name (e.g., example.com) : " DOMAIN_NAME
    read -p "Enter a username: " USERNAME
    read -sp "Enter a password: " PASSWORD
    echo "creating directory"
    DIR="/mnt/raid5_web/$USERNAME"
    mkdir -p "$DIR"
    echo "Created $DIR directory ... "
    useradd $USERNAME
    echo "$USERNAME:$PASSWORD" | chpasswd
    smbpasswd -a $USERNAME
    echo "SMB user created"

    chown -R $USERNAME:$USERNAME "$DIR"
    chmod -R 755 "$DIR"
    chown -R $USERNAME:$USERNAME "$MAILDIR"
    chmod -R 700 "$MAILDIR"

    cat <<EOL >> /etc/samba/smb.conf
[$USERNAME]
    path = $DIR
    valid users = $USERNAME
    read only = no
EOL

    systemctl restart smb

    # Create the user's database
    mysql -u root -prootpassword -e "CREATE DATABASE ${USERNAME}_db;"
    mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON ${USERNAME}_db.* TO '$USERNAME'@'localhost' IDENTIFIED BY '$PASSWORD';"

    # Create a simple index.php file in the user's directory
    echo "<html><body><h1>Welcome, $USERNAME!</h1><p>Your database name is ${USERNAME}_db.</p><?php phpinfo(); ?></body></html>" > "$DIR/index.php"

    # Set up the virtual host for the user's website (HTTP with redirect to HTTPS)
    cat <<EOL > /etc/httpd/conf.d/001-$USERNAME.conf
<VirtualHost *:80>
    ServerName $USERNAME.$DOMAIN_NAME
    DocumentRoot /mnt/raid5_web/$USERNAME
    <Directory /mnt/raid5_web/$USERNAME>
        AllowOverride All
        Require all granted
    </Directory>
    DirectoryIndex index.php
    ErrorLog /var/log/httpd/${USERNAME}_error.log
    CustomLog /var/log/httpd/${USERNAME}_access.log combined

    # Redirect all HTTP traffic to HTTPS
    Redirect "/" "https://$USERNAME.$DOMAIN_NAME/"
</VirtualHost>

<VirtualHost *:443>
    ServerName $USERNAME.$DOMAIN_NAME
    DocumentRoot /mnt/raid5_web/$USERNAME
    <Directory /mnt/raid5_web/$USERNAME>
        AllowOverride All
        Require all granted
    </Directory>
    DirectoryIndex index.php
    SSLEngine on
    SSLCertificateFile /etc/httpd/ssl/$DOMAIN_NAME.crt
    SSLCertificateKeyFile /etc/httpd/ssl/$DOMAIN_NAME.key
    ErrorLog /var/log/httpd/${USERNAME}_ssl_error.log
    CustomLog /var/log/httpd/${USERNAME}_ssl_access.log combined
</VirtualHost>
EOL

    semanage fcontext -a -e /var/www /mnt/raid5_web
    restorecon -Rv /mnt
    systemctl restart httpd

    # Configure Postfix to handle the new user's mail
    postmap /etc/postfix/virtual
    postconf -e "virtual_alias_maps = hash:/etc/postfix/virtual"

    # Configure Dovecot to handle the new user's mail
    mkdir -p /home/$USERNAME/Maildir
    chown -R $USERNAME:$USERNAME /home/$USERNAME/Maildir

    echo "$USERNAME@$DOMAIN_NAME $USERNAME" >> /etc/postfix/virtual

    # Restart Postfix to apply changes
    systemctl restart postfix

    echo "User $USERNAME has been created with a mail account and a database."
    echo "Mail can be accessed at https://mail.$USERNAME.$DOMAIN_NAME"

    echo "Press any key to continue..."
    read -n 1 -s key
}


remove_user(){
    echo "Removing a user ... "
    echo "Users list : "
    pdbedit -L
    read -p "Enter a user to delete: " USERNAME
    userdel $USERNAME
    smbpasswd -x $USERNAME
    rm -rf /mnt/raid5_web/$USERNAME
    mysql -u root -prootpassword -e "DROP DATABASE ${USERNAME}_db;"
    rm -f /etc/httpd/conf.d/001-$USERNAME.conf
    rm -rf /home/$USERNAME/Maildir

    # Remove the user from the Roundcube database
    mysql -u root -prootpassword -e "DELETE FROM roundcubemail.users WHERE username = '$USERNAME';"

    systemctl restart httpd
    echo "User $USERNAME and their data have been removed."
}

while true; do
    clear
    display_web_menu
    read -p "Enter your choice: " web_choice
    case $web_choice in
        0) basic_setup ;;
        1) add_user ;;
        2) remove_user ;;
        q|Q) clear && echo "Exiting the user management menu." && break ;;
        *) clear && echo "Invalid choice. Please enter a valid option." ;;
    esac
done
    echo "Starting webservices"
}


ntp(){
    clear
    echo "Starting ntp"

    setup_ntp() {
    clear 

    ip_server=$(hostname -I | sed 's/ *$//')/16
    ntp_pool="server 0.pool.ntp.org iburst\\nserver 1.pool.ntp.org iburst\\nserver 2.pool.ntp.org iburst\\nserver 3.pool.ntp.org iburst"
    dnf install chrony -y
    systemctl enable --now chronyd
    timedatectl set-timezone Europe/Brussels
    echo "Time zone set to Europe/Brussels"
    timedatectl set-ntp yes
    sed -i "s|#allow 192.168.0.0/16|allow $ip_server|g" /etc/chrony.conf
    sed -i "s/pool 2.almalinux.pool.ntp.org iburst/$ntp_pool/g" /etc/chrony.conf
    systemctl restart chronyd
    echo "Chrony restarted"

    echo "Press any key to continue..."
    read -n 1 -s key
}

timezone_choice() {
    clear

    timezones=$(timedatectl list-timezones)
    echo "Available timezones:"
    PS3="Please select a timezone by number: "

    select timezone in $timezones; do
    if [[ -n $timezone ]]; then
        echo "You selected $timezone"
        break
    else
        echo "Invalid selection. Please try again."
    fi
    done

    echo "Changing timezone to $timezone..."
    timedatectl set-timezone "$timezone"

    echo -e "\nTimezone changed successfully. Current timezone is now:"
    timedatectl | grep "Time zone"

    echo "Press any key to exit..."
    read -n 1 -s key

}

timezone_display() {
    clear

    echo "System Time and Date Information"
    echo "--------------------------------"

    echo -e "\nCurrent System Date and Time:"
    date

    echo -e "\nHardware Clock (RTC) Time:"
    hwclock

    echo -e "\nCurrent Timezone:"
    timedatectl | grep "Time zone"

    echo -e "\nTimedatectl Status:"
    timedatectl status

    echo -e "\nNTP Synchronization Status (timedatectl):"
    timedatectl show-timesync --all

    if command -v chronyc &> /dev/null; then
        echo -e "\nChrony Tracking Information:"
        chronyc tracking

        echo -e "\nChrony Sources:"
        chronyc sources

        echo -e "\nChrony Source Statistics:"
        chronyc sourcestats

        echo -e "\nChrony NTP Data:"
        chronyc ntpdata
    else
        echo -e "\nChrony is not installed or not found. Skipping chrony information."
    fi

    echo "--------------------------------"
    echo "All time and date information displayed successfully."

    # chronyc tracking
    # chronyc sources
    # cat /etc/chrony.conf
    echo "Press any key to exit..."
    read -n 1 -s key
}


        clear
        display_ntp_menu
        read -p "Enter your choice: " choice
        case $choice in
            1) setup_ntp ;;
            2) timezone_choice ;;
            3) timezone_display ;;
            q|Q) clear && echo "Exiting the web server configuration wizard." && break ;;
            *) clear && echo "Invalid choice. Please enter a valid option." ;;
        esac
}

security(){

configure_clamav(){
    clear
    # Install ClamAV
    dnf update -y
    dnf install clamav -y
    # Update ClamAV database
    freshclam
    # Schedule regular scans
    # Edit the crontab file and add the daily scan command
    echo "0 2 * * * clamscan -r /" | sudo tee -a /etc/crontab
    # Enable automatic scanning on file access
    systemctl enable clamav-freshclam
    systemctl enable clamd@scan
    # Start ClamAV service
    systemctl start clamav-freshclam
    systemctl start clamd@scan
    # Verify ClamAV status
    systemctl status clamav-freshclam
    systemctl status clamd@scan
    # Configure ClamAV for local socket scanning
    sed -i 's/^#LocalSocket /LocalSocket /' /etc/clamd.d/scan.conf
    sed -i 's/^TCPSocket /#TCPSocket /' /etc/clamd.d/scan.conf
    # Restart ClamAV service to apply changes
    systemctl restart clamd@scan

    echo "Clamav Done..."
    echo "Press any key to continue..."
    read -n 1 -s key
    clear
}
    configure_fail2ban() {
        # Install Fail2Ban
        dnf install fail2ban -y

        # Configure Fail2Ban for SSH
        cat <<EOL > /etc/fail2ban/jail.d/sshd.local
    [sshd]
    enabled = true
    port = ssh
    filter = sshd
    logpath = /var/log/secure
    maxretry = 3
    bantime = 3600
    EOL

        # Configure Fail2Ban for Fedora Cockpit
        cat <<EOL > /etc/fail2ban/jail.d/cockpit.local
    [cockpit]
    enabled = true
    port = http,https
    filter = cockpit
    logpath = /var/log/secure
    maxretry = 3
    bantime = 3600
EOL

        # Restart Fail2Ban service
        systemctl enable --now fail2ban

        echo "Fail2Ban configured for SSH and Fedora Cockpit."
        echo "Press any key to continue..."
        read -n 1 -s key
    }
    configure_clamav
    configure_fail2ban

}


backup(){
    clear
    lsblk

    read -p "Enter the disk name to use for backup (e.g., sdb): " BACKUP_DISK
    echo "Selected disk for backup: $BACKUP_DISK"
    # Rest of the backup code goes here

    # Create a mount point for the backup disk
    mkdir /mnt/backup

    # Mount the backup disk
    mount /dev/$BACKUP_DISK /mnt/backup

    # Format the disk in ext4
    mkfs.ext4 /dev/$BACKUP_DISK

    # Create a backup log file
    touch /mnt/backup/backup.log

    # Append a timestamp to the log file
    echo "$(date) - Backup started" >> /mnt/backup/backup.log

    # Create a directory with the current date and time
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    mkdir /mnt/backup/$TIMESTAMP

    # Use rsync to backup the /mnt/raid5_share directory
    rsync -avz /mnt/raid5_share /mnt/backup/$TIMESTAMP/raid5_share

    # Use rsync to backup each directory from raid5_web on /mnt/backup/$TIMESTAMP/raid5_web
    rsync -avz /mnt/raid5_web /mnt/backup/$TIMESTAMP/raid5_web

    # Create a directory to store user databases
    mkdir /mnt/backup/$TIMESTAMP/user_databases

    # Backup each user's database
    while IFS= read -r USERNAME; do
        mysqldump -u root -prootpassword ${USERNAME}_db > /mnt/backup/$TIMESTAMP/user_databases/${USERNAME}_db.sql
    done < <(pdbedit -L | cut -d: -f1)

    # Append a timestamp to the log file
    echo "$(date) - User databases backed up" >> /mnt/backup/backup.log
       
    echo "Press any key to continue..."
    read -n 1 -s key
}

logs(){
    clear

    echo "Starting logs"
}


main() {
    while true; do
        clear
        display_menu
        read -p "Enter your choice: " choice
        case $choice in
            0) set_hostname ;;
            1) raid ;;
            2) ssh ;;
            3) unauthshare ;;
            4) webservices ;;
            5) ntp ;;
            6) security ;;
            7) backup ;;
            8) logs ;;
            x) testing ;;
            q|Q) clear && echo "Exiting the web server configuration wizard." && exit ;;
            *) clear && echo "Invalid choice. Please enter a valid option." ;;
        esac
    done
}

main
