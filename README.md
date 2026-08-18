# Projeto Korp — Infraestrutura, Observabilidade e Automação

Projeto desenvolvido como solução para o desafio técnico da **Korp**, envolvendo desenvolvimento de uma aplicação HTTP em Go, conteinerização com Docker, proxy reverso com NGINX, monitoramento com Prometheus e Grafana e automação completa da infraestrutura utilizando Ansible.

Como extensão da solução proposta no desafio, também foi implementada uma infraestrutura em **AWS utilizando Terraform**, permitindo provisionar o ambiente de forma declarativa através de Infrastructure as Code (IaC).

---

## 📋 Sumário

* [Sobre o projeto](#-sobre-o-projeto)
* [Arquitetura](#-arquitetura)
* [Tecnologias utilizadas](#-tecnologias-utilizadas)
* [Parte 1 — Serviço HTTP e Docker](#-parte-1--serviço-http-e-docker)
* [Parte 2 — Monitoramento e Observabilidade](#-parte-2--monitoramento-e-observabilidade)
* [Parte 3 — Automação com Ansible](#-parte-3--automação-com-ansible)
* [Extensão — AWS com Terraform](#-extensão--aws-com-terraform)
* [Estrutura do projeto](#-estrutura-do-projeto)
* [Funcionamento da aplicação](#-funcionamento-da-aplicação)
* [Execução local](#-execução-local)
* [Provisionamento com Ansible](#-provisionamento-com-ansible)
* [Infraestrutura AWS](#-infraestrutura-aws)
* [Preservação do Elastic IP](#-preservação-do-elastic-ip)
* [Validação](#-validação)
* [Decisões técnicas](#-decisões-técnicas)
* [Segurança](#-segurança)
* [Conclusão](#-conclusão)

---

# 🚀 Sobre o projeto

O objetivo do projeto é construir e automatizar um ambiente completo para execução, exposição, monitoramento e provisionamento de um serviço HTTP.

O serviço principal foi desenvolvido em **Golang** e disponibilizado através de containers Docker.

A arquitetura utiliza:

* **Go** para desenvolvimento da aplicação;
* **Docker** para conteinerização;
* **Docker Compose** para orquestração dos serviços;
* **Docker Bridge Network** para comunicação entre containers;
* **NGINX** como proxy reverso;
* **Prometheus** para coleta de métricas;
* **Grafana** para visualização;
* **Ansible** para automação e provisionamento;
* **Terraform** para provisionamento da infraestrutura AWS.

A solução foi estruturada para que o ambiente possa ser reconstruído de maneira automatizada, reduzindo a necessidade de configuração manual.

---

# 🏗️ Arquitetura

A arquitetura principal do projeto pode ser representada da seguinte maneira:

```text
                         ┌─────────────────────┐
                         │       Cliente       │
                         │       Browser       │
                         │        curl         │
                         └──────────┬──────────┘
                                    │
                                    │ HTTP :80
                                    ▼
                         ┌─────────────────────┐
                         │       NGINX         │
                         │   Reverse Proxy     │
                         └──────────┬──────────┘
                                    │
                                    │ HTTP :8080
                                    ▼
                         ┌─────────────────────┐
                         │ http-server-projeto │
                         │       -korp         │
                         │       Go            │
                         └──────────┬──────────┘
                                    │
                                    │ métricas
                                    ▼
                         ┌─────────────────────┐
                         │     Prometheus      │
                         │       Metrics       │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │      Grafana        │
                         │     Dashboard       │
                         └─────────────────────┘
```

Os containers são conectados através de uma rede Docker do tipo **bridge**, permitindo que os serviços se comuniquem utilizando seus nomes dentro da rede.

---

# 🛠️ Tecnologias utilizadas

| Tecnologia         | Função                          |
| ------------------ | ------------------------------- |
| Go                 | Desenvolvimento do serviço HTTP |
| Docker             | Conteinerização                 |
| Docker Compose     | Execução dos containers         |
| NGINX              | Proxy reverso                   |
| Prometheus         | Coleta de métricas              |
| Grafana            | Visualização e dashboard        |
| Ansible            | Automação do ambiente           |
| Terraform          | Infrastructure as Code          |
| AWS EC2            | Servidor da infraestrutura      |
| AWS VPC            | Rede da infraestrutura          |
| AWS Security Group | Controle de acesso              |
| AWS Elastic IP     | Endereço IP público persistente |
| Linux              | Ambiente de execução            |

---

# 🟦 Parte 1 — Serviço HTTP e Docker

## Aplicação Go

O serviço foi desenvolvido em **Golang** e possui o nome:

```text
http-server-projeto-korp
```

A aplicação recebe requisições na porta:

```text
8080
```

O endpoint principal é:

```text
GET /projeto-korp
```

A resposta possui o seguinte formato:

```json
{
  "nome": "Projeto Korp",
  "horario": "2026-08-16T17:00:00Z"
}
```

O horário é obtido dinamicamente em **UTC** a cada requisição.

Isso garante que a aplicação não dependa de um horário fixo configurado previamente.

---

## Dockerfile

A aplicação possui um `Dockerfile` responsável por construir a imagem do serviço.

O processo é dividido conceitualmente em:

```text
Código Go
   │
   ▼
Docker build
   │
   ▼
Imagem Docker
   │
   ▼
Container
   │
   ▼
http-server-projeto-korp:8080
```

---

# 🌐 Rede Docker

Foi criada uma rede Docker no modo:

```text
bridge
```

A rede permite que os containers se comuniquem internamente.

A aplicação Go não precisa expor sua porta diretamente para o host.

O acesso externo ocorre através do NGINX.

---

# 🔀 NGINX — Proxy Reverso

O NGINX atua como proxy reverso entre o cliente e a aplicação.

Fluxo:

```text
Cliente
   │
   │ :80
   ▼
NGINX
   │
   │ :8080
   ▼
http-server-projeto-korp
```

A configuração está localizada em:

```text
nginx/http-server-projeto-korp.conf
```

O NGINX recebe a requisição externa e encaminha para o serviço Go através da rede Docker.

O objetivo é evitar que a aplicação precise ser diretamente exposta ao host.

---

# 🐳 Docker Compose

O `docker-compose.yml` é responsável por definir e executar os serviços necessários.

Entre eles:

* `http-server-projeto-korp`
* `nginx`
* `prometheus`
* `grafana`

A aplicação Go permanece acessível internamente pela rede Docker, enquanto o NGINX disponibiliza a porta HTTP para acesso externo.

---

# 📊 Parte 2 — Monitoramento e Observabilidade

A segunda etapa adiciona observabilidade ao serviço.

O objetivo é permitir acompanhar o comportamento da aplicação através de métricas.

Foram utilizados:

```text
http-server-projeto-korp
        │
        │ métricas Prometheus
        ▼
   Prometheus
        │
        ▼
     Grafana
```

O desafio determina como métricas obrigatórias:

* disponibilidade do serviço;
* volume de requisições.

As métricas são disponibilizadas seguindo o padrão utilizado pelo Prometheus.

---

# 📈 Prometheus

O Prometheus é responsável por coletar as métricas disponibilizadas pela aplicação.

Sua configuração está em:

```text
prometheus.yml
```

O Prometheus realiza o scraping do serviço e armazena as séries temporais coletadas.

---

# 📊 Grafana

O Grafana é utilizado para visualizar as métricas coletadas pelo Prometheus.

Foram utilizados arquivos de provisionamento para automatizar a configuração do ambiente.

Estrutura:

```text
files/
└── grafana/
    ├── dashboards/
    │   └── http-server-projeto-korp-dashboard.json
    │
    └── provisioning/
        ├── dashboards/
        │   └── dashboard.yml
        │
        └── datasources/
            └── datasources.yml
```

Isso permite que o Grafana seja configurado automaticamente durante a implantação.

Essa abordagem atende inclusive ao bônus proposto no desafio, que menciona o provisionamento automatizado através de arquivos como `datasources.yml`, `dashboards.yml` e o JSON do dashboard.

---

# ⚙️ Parte 3 — Automação com Ansible

A terceira etapa consiste em automatizar o processo de configuração do ambiente.

O arquivo principal é:

```text
playbook.yml
```

O Ansible é responsável por automatizar tarefas como:

* instalação/configuração do Docker;
* criação da rede;
* preparação da aplicação;
* build da imagem;
* configuração do Docker Compose;
* configuração do NGINX;
* configuração do Prometheus;
* configuração do Grafana;
* execução dos containers;
* validação do serviço.

O objetivo é evitar que o ambiente dependa de uma sequência manual de comandos.

---

# ▶️ Execução com Ansible

Após configurar o inventário:

```text
inventory.ini
```

o ambiente pode ser provisionado através do playbook:

```bash
ansible-playbook playbook.yml
```

A proposta do desafio é justamente que todo o ambiente seja provisionado utilizando um único comando Ansible.

---

# ☁️ Extensão — AWS com Terraform

## Por que Terraform?

A utilização da AWS **não fazia parte dos requisitos obrigatórios do desafio**.

A infraestrutura AWS foi adicionada por iniciativa própria como uma extensão do projeto, com o objetivo de demonstrar conhecimentos adicionais de:

* Cloud Computing;
* Infrastructure as Code;
* AWS;
* Terraform;
* redes;
* segurança;
* provisionamento automatizado.

Dessa forma, o projeto não fica limitado a uma execução exclusivamente local.

A infraestrutura foi descrita utilizando Terraform, permitindo que os recursos da AWS sejam definidos como código.

---

# 🏗️ Infraestrutura AWS

A infraestrutura foi organizada utilizando Terraform.

Estrutura:

```text
terraform/
├── ansible.tf
├── ec2.tf
├── main.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── security.tf
├── variables.tf
├── versions.tf
├── terraform.tfvars.example
└── .terraform.lock.hcl
```

---

## Recursos provisionados

A infraestrutura contempla componentes como:

```text
AWS
│
├── VPC
│
├── Subnet
│
├── Security Group
│
├── EC2
│
└── Elastic IP
```

A EC2 funciona como ambiente Linux para execução da infraestrutura automatizada pelo Ansible.

---

# 🔐 Security Group

O Security Group é utilizado para controlar o acesso à instância.

As regras são definidas através do Terraform.

O objetivo é permitir somente os acessos necessários para operação e administração do ambiente.

O acesso SSH é restrito ao endereço IP autorizado configurado através das variáveis.

---

# 🌍 Elastic IP

Foi utilizado um **Elastic IP** para manter um endereço público estável para a infraestrutura.

Isso é importante porque a aplicação e os serviços podem ser acessados através de um endereço público persistente.

O Elastic IP também foi tratado com atenção durante o processo de alteração da infraestrutura para evitar sua perda durante operações de Terraform.

---

# ♻️ Preservação do Elastic IP durante alterações

Quando é necessário destruir e recriar parte da infraestrutura, o Elastic IP pode ser removido do gerenciamento do Terraform antes do `destroy`.

Exemplo:

```bash
terraform state rm aws_eip.korp
```

Depois:

```bash
terraform destroy
```

Após a recriação da infraestrutura, o Elastic IP existente pode ser importado novamente:

```bash
terraform import aws_eip.korp eipalloc-XXXXXXXX
```

E então:

```bash
terraform apply
```

Dessa forma, o recurso existente pode continuar sendo utilizado sem necessariamente criar um novo Elastic IP.

> O ID `eipalloc-XXXXXXXX` deve ser substituído pelo ID real do Elastic IP existente na AWS.

---

# 🔧 Terraform

## Inicialização

Dentro do diretório Terraform:

```bash
terraform init
```

## Validação

```bash
terraform validate
```

## Planejamento

```bash
terraform plan
```

## Aplicação

```bash
terraform apply
```

Para confirmar:

```text
yes
```

---

# ⚠️ Variáveis e informações sensíveis

O arquivo:

```text
terraform.tfvars
```

não deve ser versionado no GitHub.

Por esse motivo, o projeto possui:

```text
terraform.tfvars.example
```

Esse arquivo serve como modelo para configuração.

Exemplo:

```hcl
aws_region = "sa-east-1"

ami_id = "ami-XXXXXXXX"

instance_type = "t3.micro"

key_name = "korpkey"

allowed_ssh_cidr = "SEU_IP/32"

allowed_monitoring_cidr = "SEU_IP/32"

vpc_cidr = "10.0.0.0/16"

subnet_cidr = "10.0.1.0/24"

private_ip = "10.0.1.10"

root_volume_size = 40
```

Após criar o arquivo real:

```bash
terraform.tfvars
```

os valores específicos da infraestrutura devem ser preenchidos localmente.

---

# 🔒 Segurança do repositório

O projeto utiliza `.gitignore` para evitar o versionamento de informações sensíveis e arquivos gerados localmente.

Entre os arquivos ignorados estão:

```text
*.pem
*.key
.env
*.tfvars
*.tfstate
.terraform/
*.bak
```

O arquivo de exemplo:

```text
terraform.tfvars.example
```

é mantido no repositório para demonstrar quais variáveis precisam ser configuradas.

---

# 🧪 Execução local

Para executar o ambiente localmente:

```bash
docker compose up -d --build
```

Verificar os containers:

```bash
docker ps
```

Verificar os logs:

```bash
docker compose logs
```

---

# 🔎 Teste da aplicação

O teste principal definido pelo desafio é:

```bash
curl http://localhost:80/projeto-korp
```

A resposta esperada possui a estrutura:

```json
{
  "nome": "Projeto Korp",
  "horario": "..."
}
```

O campo `horario` deve ser atualizado dinamicamente a cada requisição.

O desafio especifica esse teste como validação do funcionamento do ambiente.

---

# 🔍 Verificação dos serviços

Containers:

```bash
docker ps
```

Logs da aplicação:

```bash
docker compose logs http-server-projeto-korp
```

Logs do NGINX:

```bash
docker compose logs nginx
```

Logs do Prometheus:

```bash
docker compose logs prometheus
```

Logs do Grafana:

```bash
docker compose logs grafana
```

---

# 📊 Acessos

Em execução local, os principais serviços podem ser acessados através das portas configuradas no `docker-compose.yml`.

### Aplicação

```text
http://localhost/projeto-korp
```

### Grafana

```text
http://localhost:3000
```

### Prometheus

```text
http://localhost:9090
```

> Em uma implantação AWS, o acesso externo depende das regras configuradas no Security Group e dos outputs fornecidos pelo Terraform.

---

# 📁 Estrutura do projeto

```text
korp-work/
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
├── terraform/
│   ├── ansible.tf
│   ├── ec2.tf
│   ├── main.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── security.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   ├── versions.tf
│   └── .terraform.lock.hcl
│
├── ansible.cfg
├── docker-compose.yml
├── inventory.ini
├── playbook.yml
├── prometheus.yml
└── .gitignore
```

---

# 🧠 Decisões técnicas

## Go

Go foi utilizado para criar o serviço HTTP por ser uma linguagem adequada para aplicações leves, performáticas e facilmente distribuídas através de containers.

## Docker

Docker fornece isolamento e portabilidade para a aplicação.

Isso permite executar o mesmo serviço em diferentes ambientes sem depender diretamente das configurações do sistema operacional.

## NGINX

O NGINX foi escolhido como proxy reverso para separar o acesso externo da aplicação.

Isso permite que a aplicação permaneça acessível apenas dentro da rede Docker.

## Prometheus

Prometheus foi utilizado por possuir um modelo de coleta adequado para métricas de aplicações e infraestrutura.

## Grafana

Grafana fornece uma camada de visualização para as métricas coletadas pelo Prometheus.

## Ansible

Ansible foi utilizado para automatizar a configuração do ambiente.

A principal vantagem é transformar uma configuração que poderia exigir diversos comandos manuais em um processo reproduzível.

## Terraform

Terraform foi utilizado como extensão do desafio para representar a infraestrutura AWS como código.

Dessa forma, a infraestrutura de Cloud também pode ser versionada, revisada e reproduzida.

---

# 🔄 Fluxo completo de provisionamento

A arquitetura completa pode ser entendida em duas camadas.

### Infraestrutura

```text
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
        Linux
```

### Configuração da aplicação

```text
Ansible
   │
   ├── Docker
   ├── Docker Network
   ├── Docker Compose
   ├── NGINX
   ├── Prometheus
   └── Grafana
          │
          ▼
     Aplicação Go
```

Portanto:

```text
Terraform
   ↓
Infraestrutura AWS
   ↓
Servidor Linux
   ↓
Ansible
   ↓
Docker
   ↓
┌───────────────────────────────┐
│ NGINX                         │
│       ↓                       │
│ Go Application                │
│       ↓                       │
│ Prometheus                    │
│       ↓                       │
│ Grafana                       │
└───────────────────────────────┘
```

---

# ✅ Requisitos do desafio

| Requisito                          | Implementação      |
| ---------------------------------- | ------------------ |
| Serviço HTTP em Go                 | ✅                  |
| Serviço `http-server-projeto-korp` | ✅                  |
| Porta 8080                         | ✅                  |
| Endpoint `/projeto-korp`           | ✅                  |
| Horário UTC dinâmico               | ✅                  |
| Dockerfile                         | ✅                  |
| Docker                             | ✅                  |
| Rede Docker bridge                 | ✅                  |
| Docker Compose                     | ✅                  |
| NGINX                              | ✅                  |
| Proxy reverso                      | ✅                  |
| Prometheus                         | ✅                  |
| Métrica de disponibilidade         | ✅                  |
| Volume de requisições              | ✅                  |
| Grafana                            | ✅                  |
| Dashboard                          | ✅                  |
| Provisionamento Grafana            | ✅                  |
| Ansible                            | ✅                  |
| Validação HTTP                     | ✅                  |
| Provisionamento automatizado       | ✅                  |
| Repositório GitHub                 | ✅                  |
| Terraform/AWS                      | ⭐ Extensão própria |

---

# 🎯 Resultado

O projeto implementa o fluxo completo solicitado no desafio:

```text
Desenvolvimento
      ↓
Containerização
      ↓
Rede Docker
      ↓
Proxy Reverso
      ↓
Monitoramento
      ↓
Dashboard
      ↓
Automação
      ↓
Infrastructure as Code
      ↓
Cloud AWS
```

Além dos requisitos originais, a infraestrutura foi estendida com Terraform e AWS para demonstrar uma abordagem mais próxima de um ambiente real de infraestrutura e DevOps.

---

# 👨‍💻 Autor

**ArthurSS-DevOps**

Projeto desenvolvido para avaliação técnica da Korp.

---

# 📌 Observação

A infraestrutura AWS e o uso de Terraform foram implementados como **extensão voluntária do desafio**, não substituindo os requisitos originais de Docker, programação, redes, servidores, monitoramento e Ansible.

O objetivo da extensão foi demonstrar conhecimentos adicionais de **Cloud, Infrastructure as Code, Terraform e AWS**, mantendo a solução principal alinhada ao escopo solicitado pela Korp.
