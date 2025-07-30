#!/bin/bash

URL="http://localhost"
DATA=$(TZ="America/Sao_Paulo" date '+%Y-%m-%d %H:%M:%S')
LOG="/home/ubuntu/monitoramento.log"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

# Dados do Telegram
TOKEN="SEU_TOKEN_AQUI"
CHAT_ID="SEU_CHAT_ID_AQUI"

# Verificar se TOKEN e CHAT_ID estão preenchidos
if [[ -z "$TOKEN" || -z "$CHAT_ID" ]]; then
    echo "Erro: Preencha TOKEN e CHAT_ID no script."
    exit 1
fi

# Criar arquivo de log se não existir
if [ ! -f "$LOG" ]; then
    touch "$LOG"
fi

# Verificar status e gerar mensagem
if [ "$STATUS" -ne 200 ]; then
    MENSAGEM="[$DATA] ⚠️ Alerta: site fora do ar! Status HTTP: $STATUS"
    echo "$MENSAGEM"
    echo "$DATA - ERRO - Site fora do ar! Status: $STATUS" >> $LOG
else
    MENSAGEM="[$DATA] ✅ Site funcionando normalmente. Status HTTP: $STATUS"
    echo "$DATA - OK - Site funcionando. Status: $STATUS" >> $LOG
fi

# Enviar mensagem para o Telegram
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$MENSAGEM" > /dev/null
