#!/bin/bash

# Variables
DOMAIN="tungtungsahur.lan"
DOC_ROOT="/var/www/$DOMAIN"
SSL_DIR="/etc/ssl/$DOMAIN"
CONF_FILE="/etc/httpd/conf.d/$DOMAIN.conf"

# Préparation
echo "[INFO] Création du dossier de certificat : $SSL_DIR"
mkdir -p "$SSL_DIR"

echo "[INFO] Génération du certificat auto-signé pour $DOMAIN"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$SSL_DIR/$DOMAIN.key" \
  -out "$SSL_DIR/$DOMAIN.crt" \
  -subj "/C=BE/ST=Hainaut/L=Mons/O=TungSahurCorp/OU=Web/CN=$DOMAIN"

# Création du dossier racine si nécessaire
mkdir -p "$DOC_ROOT"
cat <<'EOF' > "$DOC_ROOT/index.html"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bienvenue sur tungtungsahur.lan</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.0.0/css/all.min.css">
    <style>
        body {
            background-color: #0f172a;
            color: #e2e8f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
        }
        .folder-btn {
            transition: all 0.3s ease;
        }
        .folder-btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.5);
        }
        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-fadeIn {
            animation: fadeIn 0.8s ease forwards;
        }
        .logo {
            font-size: 2rem;
            font-weight: bold;
            background: linear-gradient(45deg, #3b82f6, #10b981);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: inline-block;
        }
        .bg-gradient {
            background: linear-gradient(135deg, #1e293b, #0f172a);
        }
    </style>
</head>
<body class="bg-gradient">
    <div class="container mx-auto px-4 py-8">
        <header class="mb-12 animate-fadeIn" style="animation-delay: 0.2s;">
            <div class="flex justify-between items-center">
                <div class="logo text-3xl md:text-4xl">tungtungsahur.lan</div>
                <div class="hidden md:block text-gray-400">
                    <span id="date-time"></span>
                </div>
            </div>
            <h1 class="text-3xl md:text-5xl font-bold mt-8 text-white">Bienvenue sur le réseau</h1>
            <p class="mt-4 text-blue-300 text-xl">Accès aux ressources du système</p>
        </header>

        <main class="mb-16">
            <section class="mb-12">
                <h2 class="text-2xl font-bold mb-6 text-blue-400 animate-fadeIn" style="animation-delay: 0.4s;">
                    <i class="fas fa-folder mr-2"></i> Dossiers accessibles
                </h2>
                <div class="grid-container animate-fadeIn" style="animation-delay: 0.6s;">
                    <!-- Folder 1 -->
                    <a href="http://tungtungsahur.lan/phpMyAdmin" class="folder-btn bg-gray-800 rounded-lg p-6 hover:bg-gray-700 border-l-4 border-blue-500">
                        <i class="fas fa-database text-4xl mb-4 text-blue-400"></i>
                        <h3 class="text-xl font-semibold mb-2">Base de données</h3>
                        <p class="text-gray-400 text-sm">Accès aux données système</p>
                    </a>

                    <!-- Folder 2 -->
                    <a href="http://tungtungsahur.lan/phpMyAdmin" class="folder-btn bg-gray-800 rounded-lg p-6 hover:bg-gray-700 border-l-4 border-green-500">
                        <i class="fas fa-users text-4xl mb-4 text-green-400"></i>
                        <h3 class="text-xl font-semibold mb-2">Utilisateurs</h3>
                        <p class="text-gray-400 text-sm">Gestion des comptes</p>
                    </a>

                    <!-- Folder 3 -->
                    <a href="http://tungtungsahur.lan/phpMyAdmin" class="folder-btn bg-gray-800 rounded-lg p-6 hover:bg-gray-700 border-l-4 border-yellow-500">
                        <i class="fas fa-file-alt text-4xl mb-4 text-yellow-400"></i>
                        <h3 class="text-xl font-semibold mb-2">Documents</h3>
                        <p class="text-gray-400 text-sm">Fichiers confidentiels</p>
                    </a>

                    <!-- Folder 4 -->
                    <a href="http://tungtungsahur.lan.19999" class="folder-btn bg-gray-800 rounded-lg p-6 hover:bg-gray-700 border-l-4 border-red-500">
                        <i class="fas fa-shield-alt text-4xl mb-4 text-red-400"></i>
                        <h3 class="text-xl font-semibold mb-2">Monitoring</h3>
                        <p class="text-gray-400 text-sm">Surveiller les ressources</p>
                    </a>

                    <!-- Folder 5 -->
                    <a href="http://tungtungsahur.lan/phpMyAdmin" class="folder-btn bg-gray-800 rounded-lg p-6 hover:bg-gray-700 border-l-4 border-purple-500">
                        <i class="fas fa-cogs text-4xl mb-4 text-purple-400"></i>
                        <h3 class="text-xl font-semibold mb-2">Configuration</h3>
                        <p class="text-gray-400 text-sm">Paramètres système</p>
                    </a>

                    <!-- Folder 6 -->
                    <a href="http://tungtungsahur.lan/phpMyAdmin" class="folder-btn bg-gray-800 rounded-lg p-6 hover:bg-gray-700 border-l-4 border-indigo-500">
                        <i class="fas fa-network-wired text-4xl mb-4 text-indigo-400"></i>
                        <h3 class="text-xl font-semibold mb-2">Réseau</h3>
                        <p class="text-gray-400 text-sm">Connexions et serveurs</p>
                    </a>
                </div>
            </section>

            <section class="animate-fadeIn" style="animation-delay: 0.8s;">
                <div class="bg-blue-900 bg-opacity-20 border border-blue-800 rounded-lg p-6">
                    <div class="flex items-start">
                        <i class="fas fa-info-circle text-2xl text-blue-400 mr-4 mt-1"></i>
                        <div>
                            <h3 class="text-xl font-semibold mb-2 text-blue-300">Information système</h3>
                            <p class="text-gray-300">
                                Tous les accès aux dossiers sont automatiquement journalisés. 
                                Pour toute assistance technique, contactez l'administrateur système.
                            </p>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <footer class="text-center text-gray-500 border-t border-gray-800 pt-6 animate-fadeIn" style="animation-delay: 1s;">
            <p>© 2023 tungtungsahur.lan - Système interne</p>
            <p class="mt-2 text-sm">Version 1.0.3</p>
        </footer>
    </div>

    <script>
        // Update date and time
        function updateDateTime() {
            const now = new Date();
            const options = { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            };
            document.getElementById('date-time').textContent = now.toLocaleDateString('fr-FR', options);
        }
        
        // Initial call and set interval
        updateDateTime();
        setInterval(updateDateTime, 60000);
    </script>
</body>
</html>

EOF


# Création du fichier de configuration Apache
echo "[INFO] Création du fichier de configuration Apache"
cat <<EOF > "$CONF_FILE"
<VirtualHost *:80>
    ServerName $DOMAIN
    Redirect permanent / https://$DOMAIN/
</VirtualHost>

<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot $DOC_ROOT

    SSLEngine on
    SSLCertificateFile $SSL_DIR/$DOMAIN.crt
    SSLCertificateKeyFile $SSL_DIR/$DOMAIN.key

    <Directory $DOC_ROOT>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Activation des modules nécessaires
echo "[INFO] Activation du module SSL (si nécessaire)"
dnf install -y mod_ssl

# Redémarrage du service Apache
echo "[INFO] Redémarrage d'Apache"
systemctl restart httpd

echo "[INFO] Configuration HTTPS terminée pour $DOMAIN"
