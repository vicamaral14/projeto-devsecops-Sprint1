# Projeto-devsecops-Sprint1
Monitoramento de site na AWS com alertas via Telegram.
-------------------------------------------------------------
**Desenvolvido por:** Victória Do Amaral  
**Objetivo:** Criar uma solução automatizada de monitoramento de um site Linux hospedado na AWS, com alertas em tempo real via Telegram e registros de logs no servidor.

## Etapa 1: Configuração do Ambiente
1. Criar uma VPC:
    - Nome: `VPC-Projeto`
    - CIDR: `10.0.0.0/16`
      * O CIDR usado é muito comum, pois é amplo,fexivel e evita conflito de redes locais.

2. Criar Sub-redes:
    - Selecione a VPC criada.
    - Crie 4 sub-redes:
        Nome: subnet-publica-a
        	 
       	CIDR Block: `10.0.1.0/24`
      
       Zona de disponibilidade: us-east-1a

3. Criar e Associar um Internet Gateway:
    - Nome: IGW-Projeto > Clique em Create.
    - clique em Actions > Attach to VPC > selecione sua VPC.

4. Criar Tabela de Rotas para Internet:
    - Nome: rota-publica
    - VPC: selecione sua VPC
    - Vá na aba Routes > Edit Routes > Clique em Add Route:
    - Destination: `0.0.0.0/0`
      * Qualquer ip de qualquer lugar
    - Target: selecione seu Internet Gateway
    -Vá em Subnet Associations > Edit subnet associations > Marque as duas sub-redes públicas e clique em Save.

5. Criar uma instância EC2 na AWS:
    - Colocar as tags
    - Nome da instância: O que quiser
    - AMI: Ubuntu
    - Tipo: `t2.micro` (Free Tier)
    - Sub-rede pública
    - VPC: selecione a VPC que você criou 
    - IP público ativado
    - Clique em "Create security group"
      * Nome: Sua prefrencia > pegar a chave de segurança > Regras de entrada (Inbound) > Tipo	Porta	Origem > SSH	22	e HTTP	80
        ## Chave de segurança: muito importante pegar, pois depois não pode pegar novamente depois de criado

6. Acessar a instância via SSH para realizar configurações futuras:
    - Acessar o seu PowerShel > copiar o caminho da sua chave de segurança
    - exemplo para o terminal:
      * ssh -i sua-chave.pem ubuntu@<IP-da-instância>
------------------------------------- 

## Etapa 2: Configuração do Servidor Web
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

## Etapa 3: Monitoramento e Notificações
1. Crie o arquivo: nano monito.sh
    - shell script na outro arquivo
2. Tornar executavel
    -` chmod +x /home/ubuntu/monitoramento.sh`
3. Criar bot no telegram
   - Criar bot no @BotFather > Criar novo bot > Obter o token da API > Enviar mensagem ao bot
   - Descobrir chat_id > `https://api.telegram.org/bot<SEU_TOKEN>/getUpdates`
4.  Agendamento com Cron
   - crontab -e
   - Adicionar a seguinte linha > `* * * * * /home/ubuntu/monitoramento.sh`
   - Verificar se a tarefa foi adicionada corretamente > `crontab -l`
---

## Etapa 4: Automação e Testes
1. Acessar http://<SEU_IP_PUBLICO> no navegador > Ver página HTML personalizada
2.Teste de falha simulada > `sudo systemctl stop nginx`
    * Verificar se mensagem chegou no Telegram
    * <img width="1318" height="888" alt="image" src="https://github.com/user-attachments/assets/6d966bce-bbd3-4ea4-a93f-4d739c2c1909" />
    * Verificar registro no log com `tail -f /home/ubuntu/monitoramento.log`
    * <img width="858" height="297" alt="Captura de tela 2025-07-28 160315" src="https://github.com/user-attachments/assets/7c71f416-c5f2-4158-a6f1-76d59c788df3" />

⚠️ Principais Erros e Soluções
 -  Permission denied 
    * Solução Usado chmod +x no script
 -  Falha ao salvar em /var/log
    * Caminho alterado para /home/ubuntu/monitoramento.log
 -  Horário errado nas mensagens
    * Ajustado fuso horário com timedatectl (America/Sao_Paulo)
 -  Status HTTP 000
    * Servidor Nginx estava parado, iniciado com systemctl

    



