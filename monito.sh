#!/bin/bash

URL="http://localhost"
DATA=$(date '+%Y-%m-%d %H:%M:%S')
LOG="/home/ubuntu/monitoramento.log"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

# Dados do Telegram
TOKEN="SEU_TOKEN_AQUI"
CHAT_ID="SEU_CHAT_ID_AQUI"

if [ "$STATUS" -ne 200 ]; then
    MENSAGEM="[$DATA] ⚠️ Alerta: site fora do ar! Status HTTP: $STATUS"
    echo "$DATA - ERRO - Site fora do ar! Status: $STATUS" >> $LOG
else
    MENSAGEM="[$DATA] ✅ Site funcionando normalmente. Status HTTP: $STATUS"
    echo "$DATA - OK - Site funcionando. Status: $STATUS" >> $LOG
fi

# Envia a notificação sempre
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$MENSAGEM"
