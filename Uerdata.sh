#!/bin/bash
# Atualiza o sistema
apt-get update -y
apt-get upgrade -y

# Instala Nginx e curl
apt-get install -y nginx curl

# Inicia e habilita o Nginx
systemctl start nginx
systemctl enable nginx

# Cria uma página HTML simples
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Site Monitorado</title>
</head>
<body>
  <h1>Site rodando!</h1>
  <p>Monitorado por script User Data</p>
</body>
</html>
EOF

# Cria o script de monitoramento
cat << 'SCRIPT' > /home/ubuntu/monitoramento.sh
#!/bin/bash

URL="http://localhost"
TOKEN="seu_token"
CHAT_ID="seu_id"
LOG="/home/ubuntu/monitoramento.log"

DATA=$(TZ="America/Sao_Paulo" date '+%Y-%m-%d %H:%M:%S')
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ "$STATUS" != "200" ]; then
  MSG="🚨 [$DATA] ALERTA: Site $URL está com problema! Status: $STATUS"
  curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id=$CHAT_ID \
    -d text="$MSG" > /dev/null
fi

echo "[$DATA] Status: $STATUS" >> $LOG
SCRIPT

# Dá permissão de execução pro script
chmod +x /home/ubuntu/monitoramento.sh

# Adiciona no crontab para rodar a cada 1 minuto
(crontab -l 2>/dev/null; echo "* * * * * /home/ubuntu/monitoramento.sh") | crontab -

# Ajusta dono e permissões
chown ubuntu:ubuntu /home/ubuntu/monitoramento.sh /home/ubuntu/monitoramento.log
