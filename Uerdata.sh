#!/bin/bash

# Atualiza e instala Nginx e curl
apt-get update -y
apt-get install -y nginx curl

# Inicia e habilita o Nginx
systemctl start nginx
systemctl enable nginx

# Cria uma página HTML
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Projeto AWS - DevSecOps</title>
    <style>
        body { background-color: #111; color: #f1f1f1; font-family: sans-serif; text-align: center; padding-top: 50px; }
        h1 { color: #ff69b4; }
    </style>
</head>
<body>
    <h1>Site no ar - Projeto DevSecOps</h1>
    <p>Monitorado automaticamente via script.</p>
</body>
</html>
EOF

# Cria o script de monitoramento
cat <<EOF > /home/ubuntu/monitoramento.sh
#!/bin/bash

URL="http://localhost"
DATA=\$(date '+%Y-%m-%d %H:%M:%S')
LOG="/var/log/monitoramento.log"
STATUS=\$(curl -s -o /dev/null -w "%{http_code}" \$URL)

TOKEN="SEU_TOKEN_DO_TELEGRAM"
CHAT_ID="SEU_CHAT_ID"

if [ "\$STATUS" != "200" ]; then
  MSG="⚠️ [\$DATA] Site fora do ar! Código HTTP: \$STATUS"
  curl -s -X POST "https://api.telegram.org/bot\$TOKEN/sendMessage" -d "chat_id=\$CHAT_ID&text=\$MSG"
else
  echo "[\$DATA] Site funcionando normalmente. Código: \$STATUS" >> \$LOG
fi
EOF

# Dá permissão e agenda no cron
chmod +x /home/ubuntu/monitoramento.sh
(crontab -l ; echo "* * * * * /home/ubuntu/monitoramento.sh") | crontab -
