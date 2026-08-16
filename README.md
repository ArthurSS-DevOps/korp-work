# Korp — Infraestrutura, Deploy e Observabilidade

Projeto de infraestrutura e monitoramento desenvolvido com **Terraform, Ansible, Docker, AWS, Go, Nginx, Prometheus e Grafana**.

O objetivo do projeto é provisionar uma infraestrutura completa na AWS, automatizar a configuração do servidor e disponibilizar uma aplicação Go conteinerizada, protegida por Nginx e monitorada através de Prometheus e Grafana.

---

## 📌 Visão geral

O projeto foi desenvolvido com foco em práticas de **DevOps, Infrastructure as Code (IaC), automação, observabilidade e monitoramento de aplicações**.

O fluxo geral é:

```text
                    ┌──────────────────────┐
                    │       Terraform      │
                    │                      │
                    │ AWS Infrastructure   │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │         AWS          │
                    │                      │
                    │ VPC                  │
                    │ Subnet               │
                    │ Security Group       │
                    │ EC2                  │
                    │ Elastic IP           │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │       Ansible        │
                    │                      │
                    │ Configuração do host │
                    │ Docker               │
                    │ Nginx                │
                    │ Prometheus           │
                    │ Grafana              │
                    │ Aplicação            │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │        Docker        │
                    │                      │
                    │ Go Application       │
                    │ Nginx                │
                    │ Prometheus           │
                    │ Grafana              │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │     Observabilidade  │
                    │                      │
                    │ Prometheus           │
                    │ Grafana              │
                    └──────────────────────┘
```

---

# 🚀 Tecnologias utilizadas

## Infraestrutura

* AWS
* Terraform
* VPC
* Subnet
* Security Groups
* EC2
* Elastic IP

## Automação

* Ansible
* Docker Compose

## Aplicação

* Go
* Prometheus Go client

## Proxy

* Nginx

## Observabilidade

* Prometheus
* Grafana
* Métricas da aplicação
* Métricas do runtime Go

## Versionamento

* Git
* GitHub

---

# 📂 Estrutura do projeto

```text
korp-work/
│
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── network.tf
│   ├── security.tf
│   ├── ec2.tf
│   ├── ansible.tf
│   ├── terraform.tfvars.example
│   └── .terraform.lock.hcl
│
├── app/
│   ├── Dockerfile
│   ├── go.mod
│   ├── go.sum
│   └── main.go
│
├── files/
│   └── grafana/
│       ├── dashboards/
│       │   └── http-server-projeto-korp-dashboard.json
│       │
│       └── provisioning/
│           ├── dashboards/
│           │   └── dashboard.yml
│           │
│           └── datasources/
│               └── datasources.yml
│
├── nginx/
│   └── http-server-projeto-korp.conf
│
├── docker-compose.yml
├── prometheus.yml
├── playbook.yml
├── inventory.ini
├── ansible.cfg
├── .gitignore
└── README.md
```

---

# 🏗️ Arquitetura

A infraestrutura utiliza uma VPC própria na AWS.

```text
AWS
│
└── VPC 10.0.0.0/16
    │
    └── Subnet 10.0.1.0/24
        │
        └── EC2
            │
            ├── Private IP: 10.0.1.10
            │
            └── Elastic IP
                │
                └── Acesso externo
```

A EC2 funciona como host da stack da aplicação e observabilidade.

Dentro dela são executados os containers definidos pelo Docker Compose.

---

# ☁️ Terraform

O Terraform é responsável pela criação e gerenciamento da infraestrutura AWS.

A configuração foi dividida em arquivos para manter uma separação lógica das responsabilidades.

## `provider.tf`

Configura o provider da AWS.

## `versions.tf`

Define as versões utilizadas pelo Terraform e pelos providers.

## `variables.tf`

Centraliza as variáveis utilizadas pela infraestrutura.

## `network.tf`

Responsável pelos recursos de rede, incluindo:

* VPC
* Subnet
* configuração de rede

## `security.tf`

Responsável pelos Security Groups e regras de acesso.

## `ec2.tf`

Responsável pela instância EC2 e suas configurações.

## `ansible.tf`

Relaciona a infraestrutura criada com o processo de configuração através do Ansible.

## `outputs.tf`

Exibe informações importantes após o provisionamento.

---

# ⚠️ Sobre o `main.tf`

O `main.tf` pode permanecer vazio.

Isso acontece porque o Terraform não executa somente o `main.tf`.

Todos os arquivos `.tf` existentes no mesmo diretório são carregados como uma única configuração.

Por exemplo:

```text
provider.tf
network.tf
security.tf
ec2.tf
ansible.tf
outputs.tf
```

são processados juntos pelo Terraform.

Portanto, um `main.tf` vazio não impede:

```bash
terraform plan
```

ou:

```bash
terraform apply
```

A separação dos arquivos por responsabilidade é intencional.

---

# 🔐 Variáveis do Terraform

O arquivo:

```text
terraform/terraform.tfvars
```

não deve ser enviado para o GitHub.

Ele pode conter informações específicas do ambiente.

Por isso o projeto disponibiliza:

```text
terraform/terraform.tfvars.example
```

Para configurar o ambiente:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Depois edite:

```powershell
notepad terraform.tfvars
```

Exemplo:

```hcl
aws_region = "sa-east-1"

ami_id = "AMI_ID"

instance_type = "t3.micro"

key_name = "korpkey"

allowed_ssh_cidr = "SEU_IP/32"

allowed_monitoring_cidr = "SEU_IP/32"

vpc_cidr = "10.0.0.0/16"

subnet_cidr = "10.0.1.0/24"

private_ip = "10.0.1.10"

root_volume_size = 40
```

> Nunca publique chaves privadas, credenciais AWS, arquivos `.env`, `terraform.tfstate` ou arquivos `.pem`.

---

# 🛡️ `.gitignore`

O projeto possui regras para impedir o versionamento de arquivos sensíveis e arquivos gerados localmente.

Entre eles:

```text
*.pem
*.key
.env
.terraform/
*.tfstate
*.tfstate.*
*.bak
.vscode/
.idea/
```

O objetivo é evitar que informações sensíveis ou arquivos temporários sejam enviados ao GitHub.

---

# 🐳 Docker

A aplicação e os componentes de observabilidade são executados através de Docker Compose.

O arquivo principal é:

```text
docker-compose.yml
```

A stack contém os serviços necessários para executar a aplicação e o monitoramento.

O fluxo da aplicação é:

```text
Cliente
   │
   ▼
 Nginx
   │
   ▼
Aplicação Go
   │
   ├── HTTP
   │
   └── /metrics
          │
          ▼
      Prometheus
          │
          ▼
       Grafana
```

---

# 🐹 Aplicação Go

A aplicação está localizada em:

```text
app/
```

Arquivos principais:

```text
app/
├── Dockerfile
├── go.mod
├── go.sum
└── main.go
```

A aplicação é executada dentro de um container.

Além da funcionalidade HTTP, ela disponibiliza métricas para o Prometheus.

---

# 📊 Métricas

A aplicação expõe métricas compatíveis com Prometheus.

Entre as informações utilizadas no monitoramento estão:

* disponibilidade do serviço
* volume de requisições
* total de requisições
* CPU
* memória
* goroutines
* métricas do runtime Go
* garbage collection

---

# 📈 Prometheus

O Prometheus é responsável pela coleta das métricas.

Sua configuração está em:

```text
prometheus.yml
```

O Prometheus consulta a aplicação através do endpoint de métricas.

Conceitualmente:

```text
Go Application
      │
      │ /metrics
      ▼
 Prometheus
      │
      │ PromQL
      ▼
   Grafana
```

---

# 📊 Grafana

O Grafana é utilizado para visualizar as métricas coletadas pelo Prometheus.

O dashboard está versionado em:

```text
files/grafana/dashboards/
└── http-server-projeto-korp-dashboard.json
```

O provisioning está configurado em:

```text
files/grafana/provisioning/
├── dashboards/
│   └── dashboard.yml
│
└── datasources/
    └── datasources.yml
```

Isso permite que o dashboard e o datasource sejam configurados automaticamente quando o ambiente é iniciado.

---

# 📊 Dashboard

O dashboard do projeto apresenta informações importantes sobre a aplicação.

## Disponibilidade do serviço

Exibe claramente se a aplicação está:

```text
UP
```

ou:

```text
DOWN
```

Esse painel permite verificar rapidamente a disponibilidade do serviço.

---

## Volume de requisições

Exibe a quantidade de requisições processadas ao longo do tempo.

A intenção é deixar explícita a carga de requisições recebida pela aplicação.

---

## Total de requisições

Apresenta o total acumulado de requisições observado no período selecionado.

---

## CPU da aplicação

Mostra o consumo de CPU da aplicação.

---

## Memória da aplicação

Mostra o consumo de memória do processo.

---

## Goroutines

Apresenta a quantidade de goroutines em execução.

---

## Memória Go

Exibe informações relacionadas ao gerenciamento de memória do runtime Go, incluindo:

* heap alocado
* heap em uso

---

## Garbage Collection

Apresenta informações relacionadas ao Garbage Collection do runtime Go.

---

## Status dos targets Prometheus

Permite verificar o estado dos targets monitorados pelo Prometheus.

---

# 🌐 Nginx

A configuração do Nginx está em:

```text
nginx/http-server-projeto-korp.conf
```

O Nginx funciona como camada de acesso HTTP na frente da aplicação.

Fluxo:

```text
Internet
   │
   ▼
Nginx
   │
   ▼
Go Application
```

---

# 🤖 Ansible

O Ansible automatiza a configuração da máquina criada pelo Terraform.

O playbook principal é:

```text
playbook.yml
```

O inventário é:

```text
inventory.ini
```

A configuração do Ansible está em:

```text
ansible.cfg
```

A ideia é evitar configuração manual da EC2.

Depois que a infraestrutura é provisionada pelo Terraform, o Ansible pode configurar o ambiente necessário para executar a stack.

---

# 🔄 Processo completo de deploy

O processo completo pode ser dividido em etapas.

```text
1. Terraform
      ↓
2. AWS Infrastructure
      ↓
3. EC2
      ↓
4. Ansible
      ↓
5. Docker
      ↓
6. Go Application
      ↓
7. Prometheus
      ↓
8. Grafana
```

---

# 1️⃣ Configurar o Terraform

Entre no diretório:

```powershell
cd terraform
```

Inicialize o Terraform:

```powershell
terraform init
```

Verifique a configuração:

```powershell
terraform validate
```

Depois:

```powershell
terraform plan
```

Se o plano estiver correto:

```powershell
terraform apply
```

Confirme com:

```text
yes
```

---

# 2️⃣ Verificar os outputs

Depois do `apply`:

```powershell
terraform output
```

Isso permite verificar as informações disponibilizadas pelo projeto.

Também é possível consultar:

```powershell
terraform show
```

---

# 3️⃣ Configuração através do Ansible

Depois que a EC2 estiver disponível, o Ansible pode ser utilizado para configurar o servidor.

Exemplo:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

O inventário deve apontar para o host correto e utilizar a chave SSH correspondente.

---

# 4️⃣ Docker Compose

Na EC2, verificar os containers:

```bash
docker ps
```

Para iniciar a stack:

```bash
docker compose up -d
```

Para verificar os serviços:

```bash
docker compose ps
```

Para acompanhar os logs:

```bash
docker compose logs -f
```

Para consultar um serviço específico:

```bash
docker compose logs -f grafana
```

ou:

```bash
docker compose logs -f prometheus
```

---

# 5️⃣ Verificar a aplicação

Primeiro verificar os containers:

```bash
docker ps
```

Depois verificar a aplicação.

Também é possível testar o endpoint de métricas:

```bash
curl http://localhost:<PORTA>/metrics
```

Se as métricas estiverem disponíveis, o Prometheus poderá coletá-las.

---

# 6️⃣ Verificar o Prometheus

A interface do Prometheus deve estar disponível na porta configurada no Docker Compose.

Na própria máquina:

```bash
curl http://localhost:9090
```

Também é possível acessar pelo navegador:

```text
http://IP_DO_SERVIDOR:9090
```

> Recomenda-se restringir o acesso ao Prometheus através do Security Group em ambientes reais.

---

# 7️⃣ Verificar o Grafana

O Grafana utiliza a porta:

```text
3000
```

Acesso:

```text
http://IP_DO_SERVIDOR:3000
```

Após o login, o dashboard provisionado deverá estar disponível.

---

# 🔄 Recriar a infraestrutura sem perder o Elastic IP

Uma das partes importantes deste projeto é a preservação do **Elastic IP existente**.

O Elastic IP não deve ser destruído junto com a infraestrutura caso exista a necessidade de recriar a EC2 mantendo o mesmo endereço público.

Antes de executar um `terraform destroy`, verifique o recurso:

```powershell
terraform state list
```

Procure:

```text
aws_eip.korp
```

Depois:

```powershell
terraform state show aws_eip.korp
```

Confirme que o recurso corresponde ao Elastic IP desejado.

---

# ⚠️ Remover o EIP do state antes do destroy

Para preservar o Elastic IP:

```powershell
terraform state rm aws_eip.korp
```

Esse comando **não remove o Elastic IP da AWS**.

Ele apenas remove o recurso do gerenciamento do state atual do Terraform.

Confirme:

```powershell
terraform state list
```

O recurso:

```text
aws_eip.korp
```

não deverá mais aparecer.

---

# 💥 Destroy

Agora execute:

```powershell
terraform destroy
```

Antes de confirmar, revise cuidadosamente os recursos que serão destruídos.

Se o Terraform tentar destruir:

```text
aws_eip.korp
```

**não confirme o destroy.**

O objetivo é manter o Elastic IP existente.

---

# 🔄 Importar novamente o Elastic IP

Depois que o restante da infraestrutura for destruído, o Elastic IP continua existente na AWS.

Ele pode ser importado novamente para o state:

```powershell
terraform import aws_eip.korp eipalloc-029a05aae246bb6ab
```

Depois confira:

```powershell
terraform state show aws_eip.korp
```

---

# 🔎 Verificar antes do Apply

Sempre execute:

```powershell
terraform plan
```

antes de:

```powershell
terraform apply
```

Isso permite verificar se o Terraform está interpretando corretamente o estado atual.

Se o plano estiver correto:

```powershell
terraform apply
```

Confirme:

```text
yes
```

---

# 🔐 Preservação do IP

O projeto utiliza dois conceitos diferentes de IP:

```text
10.0.1.10
```

é o endereço IP privado da EC2.

Já o endereço público, quando associado ao Elastic IP, é utilizado para acesso externo.

O Elastic IP deve ser tratado como um recurso persistente quando existe a necessidade de manter o mesmo endereço público após a recriação da infraestrutura.

---

# 🧪 Validação após o deploy

Depois da infraestrutura ser recriada, faça uma validação completa.

## 1. Verificar EC2

```bash
aws ec2 describe-instances
```

## 2. Verificar IP

Confirme que o Elastic IP continua associado corretamente.

## 3. Verificar SSH

```bash
ssh -i <sua-chave.pem> ubuntu@IP_DO_SERVIDOR
```

## 4. Verificar Docker

```bash
docker ps
```

## 5. Verificar aplicação

```bash
curl http://localhost:<PORTA>
```

## 6. Verificar métricas

```bash
curl http://localhost:<PORTA>/metrics
```

## 7. Verificar Prometheus

Confirmar que o target está:

```text
UP
```

## 8. Verificar Grafana

Acessar:

```text
http://IP_DO_SERVIDOR:3000
```

## 9. Verificar dashboard

Confirmar:

* disponibilidade do serviço
* volume de requisições
* total de requisições
* CPU
* memória
* goroutines
* memória Go
* Garbage Collection
* status dos targets Prometheus

---

# 🐛 Troubleshooting

## Grafana não abre

Verifique:

```bash
docker ps
```

Depois:

```bash
docker compose logs grafana
```

Verifique se a porta está publicada:

```bash
docker compose ps
```

Também verifique o Security Group da AWS.

---

## Prometheus não coleta métricas

Verifique:

```bash
docker compose logs prometheus
```

Teste o endpoint da aplicação:

```bash
curl http://localhost:<PORTA>/metrics
```

Depois confira os targets do Prometheus.

---

## Aplicação não responde

Verifique:

```bash
docker compose logs app
```

ou o nome correspondente ao serviço definido no `docker-compose.yml`.

Também:

```bash
docker compose ps
```

---

## Nginx não responde

Verifique:

```bash
docker compose logs nginx
```

E valide a configuração:

```bash
nginx -t
```

caso o Nginx esteja sendo executado diretamente no host.

---

# 🧹 Remover ambiente

Para remover a infraestrutura criada pelo Terraform:

```powershell
terraform destroy
```

**Atenção:** se existir um Elastic IP que precisa ser preservado, siga primeiro o procedimento de remoção do EIP do state descrito anteriormente.

---

# 🔀 Git e GitHub

O projeto é versionado utilizando Git.

Depois de realizar alterações:

```powershell
git status
```

Adicionar arquivos:

```powershell
git add .
```

Criar commit:

```powershell
git commit -m "feat: descrição da alteração"
```

Enviar para o GitHub:

```powershell
git push origin main
```

Verificar o estado:

```powershell
git status
```

O esperado após o push:

```text
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# 📌 Boas práticas utilizadas

O projeto procura aplicar algumas práticas importantes de DevOps:

* Infrastructure as Code com Terraform
* configuração automatizada com Ansible
* containers com Docker
* separação de responsabilidades
* versionamento com Git
* infraestrutura reproduzível
* monitoramento com Prometheus
* visualização com Grafana
* exposição de métricas da aplicação
* utilização de arquivos `.tfvars.example`
* proteção de arquivos sensíveis através do `.gitignore`
* preservação de recursos persistentes, como Elastic IP
* validação através de `terraform plan`
* organização da infraestrutura em múltiplos arquivos Terraform

---

# 🔒 Segurança

Nunca versionar:

```text
*.pem
*.key
.env
terraform.tfvars
terraform.tfstate
terraform.tfstate.*
```

Também não coloque:

* Access Keys da AWS
* Secret Keys
* senhas
* tokens
* chaves privadas
* credenciais de banco
* credenciais de APIs

no repositório.

Para informações específicas do ambiente, utilize arquivos locais ignorados pelo Git ou mecanismos apropriados de gerenciamento de secrets.

---

# 📚 Comandos principais

## Terraform

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform show
terraform state list
terraform state show aws_eip.korp
terraform destroy
```

## Ansible

```bash
ansible-playbook -i inventory.ini playbook.yml
```

## Docker

```bash
docker compose up -d
docker compose down
docker compose ps
docker compose logs -f
docker ps
```

## Git

```bash
git status
git add .
git commit -m "mensagem"
git push origin main
```

---

# 🎯 Objetivo do projeto

O Projeto Korp foi desenvolvido como um laboratório prático de **DevOps e infraestrutura em nuvem**, reunindo em um único ambiente conceitos de:

```text
Infrastructure as Code
        +
Cloud
        +
Automation
        +
Containers
        +
Reverse Proxy
        +
Application
        +
Monitoring
        +
Observability
```

O resultado é uma infraestrutura automatizada capaz de provisionar uma aplicação Go na AWS, configurar o ambiente através do Ansible, executar os serviços utilizando Docker e disponibilizar métricas através de Prometheus e Grafana.

---

# 👨‍💻 Autor

**ArthurSS-DevOps**

Projeto desenvolvido para estudos práticos de:

* DevOps
* Cloud Computing
* AWS
* Terraform
* Ansible
* Docker
* Linux
* Prometheus
* Grafana
* Observabilidade
* Infrastructure as Code

---

# ⭐ Próximas evoluções

Possíveis melhorias futuras para o projeto:

* CI/CD com GitHub Actions
* gerenciamento de secrets
* HTTPS com Let's Encrypt
* domínio próprio
* alertas do Prometheus/Grafana
* integração com Alertmanager
* logs centralizados
* tracing distribuído
* métricas adicionais da aplicação
* testes automatizados
* deploy automatizado após alterações no GitHub
* Remote State do Terraform
* Terraform State Lock
* separação entre ambientes `dev`, `staging` e `prod`

---

## 📌 Resumo do fluxo

```text
GitHub
  │
  ▼
Terraform
  │
  ▼
AWS
  │
  ├── VPC
  ├── Subnet
  ├── Security Group
  ├── EC2
  └── Elastic IP
          │
          ▼
       Ansible
          │
          ▼
       Docker
          │
          ├── Nginx
          ├── Go
          ├── Prometheus
          └── Grafana
                    │
                    ▼
              Dashboard
                    │
                    ├── Disponibilidade do serviço
                    ├── Volume de requisições
                    ├── Total de requisições
                    ├── CPU
                    ├── Memória
                    ├── Goroutines
                    ├── Memória Go
                    ├── Garbage Collection
                    └── Status dos Targets
```

**Korp — Infrastructure, Deployment and Observability.**
