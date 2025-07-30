## 🚀 Projeto DevSecOps - Sprint 1

Monitoramento de Site na AWS com Alertas via Telegram

Desenvolvido por: Victória do Amaral

---
🎯 Objetivo
Automatizar o monitoramento de um site hospedado em uma instância Linux (EC2) na AWS, com:
* Notificações via Telegram em caso de falha;
* Registro de logs no servidor;
* Infraestrutura montada do zero com VPC, sub-redes, gateway e regras de acesso.
------

## Sumário
- [Etapa 1 Configuração do Ambiente](#etapa-1-configuracao-do-ambiente)
- [Etapa 2 Configuração do Servidor Web](#etapa-2-configuracao-do-servidor-web)
- [Etapa 3 Monitoramento e Notificações](#etapa-3-monitoramento-e-notificacoes)
- [Etapa 4 Automação e Testes](#etapa-4-automacao-e-testes)
- [Principais Erros e Soluções](#principais-erros-e-solucoes)
- [Criar User Data](#criar-user-data)

## 🧱 Etapa 1 - Configuração do Ambiente
Acesse o console da AWS: https://console.aws.amazon.com/

✅ Criar uma VPC
Onde encontrar: Console da AWS → digite “VPC” na busca → clique em VPCs
* Clique em Create VPC
* Nome: VPC-Projeto
* IPv4 CIDR: 10.0.0.0/16 (espaço grande e sem conflito com redes caseiras)
  
✅ Criar Sub-redes
Onde encontrar: Dentro da VPC → menu lateral → Subnets
* Crie 4 sub-redes (2 publicas e 2 privadas):
Exemplo:
* Nome: subnet-publica-a
    * CIDR: Escolha uma
    * Zona: us-east-1a
* Nome: subnet-publica-b
    * CIDR: Escolha uma
    * Zona: us-east-1b

✅ Criar Internet Gateway
Onde encontrar: Menu lateral da VPC → Internet Gateways
* Clique em Create Internet Gateway → Nome: IGW-Projeto
* Depois de criado, vá em Actions → Attach to VPC → selecione a VPC-Projeto

✅ Criar Tabela de Rotas para Internet:
Onde encontrar: Menu lateral da VPC → Route Tables
    - Nome: rota-publica
    - VPC: selecione sua VPC
    - Vá na aba Routes > Edit Routes > Clique em Add Route:
    - Destination: `0.0.0.0/0`
      * Qualquer ip de qualquer lugar
    - Target: selecione seu Internet Gateway
    -Vá em Subnet Associations > Edit subnet associations > Marque as duas sub-redes públicas e clique em Save.

✅ Criar Instância EC2
Onde encontrar: Console da AWS → digite “EC2” → clique em Instâncias
    - Colocar as tags
    - Nome da instância: O que quiser
    - AMI: Ubuntu
    - Tipo: `t2.micro` (Free Tier)
    - Sub-rede pública
    - VPC: selecione a VPC que você criou 
    - IP público ativado
    - Clique em "Create security group"
      * Nome: Sua prefrencia > pegar a chave de segurança > Regras de entrada (Inbound) > Tipo	Porta	Origem > SSH	22	e HTTP	80
      * Chave de segurança: muito importante pegar, pois depois não pode pegar novamente depois de criado

✅ Acesso via SSH
No seu terminal ou PowerShell:
    - Copiar o caminho da sua chave de segurança
    - exemplo para o terminal:
      * ssh -i sua-chave.pem ubuntu@<IP-da-instância>
------------------------------------- 

## 🌐 Etapa 2 - Configuração do Servidor Web
Conectar a ec2
1.  Instalar Nginx no terminal da ec2
    - sudo apt update > sudo apt install nginx -y
2. Criar página HTML
 - `echo "<h1>Bem-vindo ao Projeto DevSecOps!</h1>" | sudo tee /var/www/html/index.html`
3. Verifique se o Nginx está funcionando
    - sudo systemctl status nginx > sudo systemctl start nginx
4. Teste no navegador
    - `http://SEU_IP_PUBLICO_DA_EC2`
------

## 📡 Etapa 3 - Monitoramento e Notificações
1. Criar o Bot no Telegram
    * Acesse o @BotFather no Telegram.
    * Crie um novo bot com o comando: /newbot.
    * Escolha um nome e um nome de usuário para o bot.
    * Copie o token da API fornecido.
2. Enviar uma mensagem para seu bot
    * Acesse seu bot recém-criado no Telegram.
    * Envie qualquer mensagem (ex: "teste") para iniciar a conversa.
3. Obter o chat_id
    * Acesse no navegador o seguinte link, substituindo SEU_TOKEN pelo token do seu bot:

    * https://api.telegram.org/botSEU_TOKEN/getUpdates
    * No JSON retornado, localize o campo "chat":{"id":...} → esse é o seu chat_id.
   4.Criar Shell sript
    * Código do shell script no monito.sh
    * Escreva no terminal nano monito.sh
    * Salve Ctrl +o e saia ctrl + x
    * De a permissão chmod +x monito.sh

---

## 🔁 Etapa 4 - Automação e Testes
1. Acessar http://<SEU_IP_PUBLICO> no navegador > Ver página HTML personalizada
   <img width="1229" height="811" alt="Captura de tela 2025-07-29 142555" src="https://github.com/user-attachments/assets/9bd27bdd-6aee-453a-92be-813bcf1ba92e" />

2.Teste de falha simulada > `sudo systemctl stop nginx`

  * Verificar se mensagem chegou no Telegram
    <img width="775" height="100" alt="Captura de tela 2025-07-29 142722" src="https://github.com/user-attachments/assets/5b370fbf-5b7c-469b-9757-117beae68779" />

 * Verificar registro no log com `tail -f /home/ubuntu/monitoramento.log`
   <img width="685" height="47" alt="Captura de tela 2025-07-29 142805" src="https://github.com/user-attachments/assets/9283a36b-f335-4eaa-be4a-083d4a7efba9" />

-----
## 📜 Criar User Data
* Para ter o código acesse o https://github.com/vicamaral14/projeto-devsecops-Sprint1/commit/0aa4d40e00280692d3447d5e680f22a139e29642
1. Escrevi um script bash que será executado automaticamente na inicialização da instância.
    * O script faz a atualização do sistema, instala o Nginx e o curl.
    * Inicia e habilita o Nginx para iniciar junto com a instância.
    * Cria uma página HTML simples para teste.
    * Configura um script de monitoramento para verificar a disponibilidade do site.
    * Configura notificações via Telegram para alertas.

2. Adicionar o script na criação da instância:
    * No console da AWS, ao criar a instância EC2, na etapa Configurar detalhes da instância, colei o script no campo User Data.
    * Certifiquei-me que o script estivesse em formato bash iniciando com #!/bin/bash.

3. Definir as permissões da instância e rede:
    * Configurei o grupo de segurança para permitir acesso HTTP (porta 80) para testar o Nginx.
    * Configurei a VPC e sub-rede pública para a instância ter acesso externo.

4. Inicializar a instância:
    * Lancei a instância e aguardei o script User Data ser executado automaticamente.
    * Verifiquei se o Nginx estava rodando e se a página HTML estava acessível via navegador.

5. Testar o monitoramento:
    * O script de monitoramento roda em background e verifica o status do servidor.
    * Se o site ficar fora do ar, o script envia uma notificação para um chat do Telegram via bot.
