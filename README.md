# Projeto Korp — HTTP Service, Docker, Observabilidade e Ansible

Implementação do desafio técnico da Korp, envolvendo desenvolvimento de um serviço HTTP em Golang, conteinerização com Docker, proxy reverso com NGINX, monitoramento com Prometheus e Grafana e automação completa do ambiente utilizando Ansible.

Como etapa adicional, o projeto também utiliza Terraform para provisionamento da infraestrutura AWS.

---

## 📋 Sobre o desafio

O objetivo do desafio é avaliar conhecimentos práticos em:

* Golang
* Docker
* Docker Compose
* Redes
* Linux
* NGINX
* Prometheus
* Grafana
* Ansible
* Automação de infraestrutura

O projeto foi estruturado para que o ambiente possa ser provisionado automaticamente em uma máquina Linux por meio de um único playbook Ansible.

A implementação segue as três etapas propostas no desafio:

1. Criação do serviço e arquitetura do ambiente
2. Monitoramento e observabilidade
3. Automação com Ansible

O desafio também solicita que todos os arquivos sejam disponibilizados em um repositório público do GitHub.

---

# 🏗️ Arquitetura

A arquitetura final possui os seguintes componentes:

```text
                         Internet
                            │
                            │ HTTP :80
                            ▼
                    ┌─────────────────┐
                    │      NGINX      │
                    │  Reverse Proxy  │
                    │      :80        │
                    └────────┬────────┘
                             │
                             │ HTTP :8080
                             ▼
                 ┌─────────────────────────┐
                 │ http-server-projeto-korp│
                 │        Golang           │
                 │         :8080           │
                 └────────────┬────────────┘
                              │
                              │ /metrics
                              ▼
                    ┌─────────────────┐
                    │    Prometheus   │
                    │      :9090      │
                    └────────┬────────┘
                             │
                             │ PromQL
                             ▼
                    ┌─────────────────┐
                    │     Grafana     │
                    │      :3000      │
                    └─────────────────┘
```

Todos os containers utilizam uma rede Docker do tipo `bridge`, permitindo a comunicação entre os serviços através da rede interna.

O serviço da aplicação não expõe diretamente a porta 8080 para o host. O acesso externo é realizado através do NGINX, que funciona como proxy reverso.

Essa configuração atende à arquitetura solicitada no desafio.

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
├── nginx/
│   └── http-server-projeto-korp.conf
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
├── terraform/
│   ├── .terraform.lock.hcl
│   ├── ansible.tf
│   ├── ec2.tf
│   ├── main.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── security.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   └── versions.tf
│
├── docker-compose.yml
├── prometheus.yml
├── inventory.ini
├── playbook.yml
├── ansible.cfg
└── .gitignore
```

Arquivos sensíveis, como `terraform.tfvars`, estados do Terraform, chaves privadas e arquivos `.env`, não devem ser versionados.

---

# 1. Serviço HTTP em Golang

O serviço foi desenvolvido em Golang com o nome:

```text
http-server-projeto-korp
```

A aplicação recebe requisições na porta:

```text
8080
```

E disponibiliza o endpoint:

```text
GET /projeto-korp
```

A resposta possui o formato:

```json
{
  "nome": "Projeto Korp",
  "horario": "2026-08-15T02:24:05Z"
}
```

O campo `horario` é gerado dinamicamente utilizando o horário atual em UTC a cada requisição.

Essa implementação atende ao requisito de criação do servidor HTTP e do endpoint especificado no desafio.

---

# 2. Docker

A aplicação possui um `Dockerfile` responsável pela construção da imagem e execução do serviço dentro de um container.

O objetivo é separar a aplicação do ambiente do host e permitir que ela seja executada de maneira reproduzível.

A aplicação é posteriormente utilizada pelo Docker Compose.

---

# 3. Rede Docker

Foi criada uma rede Docker no modo `bridge`.

A rede permite que os containers se comuniquem internamente utilizando a rede Docker, sem necessidade de expor todas as portas diretamente para o host.

A comunicação principal ocorre da seguinte forma:

```text
NGINX
  │
  │ http-server-projeto-korp:8080
  ▼
Aplicação Golang
```

O nome do serviço Docker pode ser utilizado para resolução interna entre containers.

---

# 4. Docker Compose

O `docker-compose.yml` reúne os componentes necessários para executar o ambiente.

Os principais serviços são:

* `http-server-projeto-korp`
* `nginx`
* `prometheus`
* `grafana`

## Aplicação

A aplicação Golang:

* utiliza a imagem construída pelo projeto;
* conecta-se à rede Docker;
* escuta na porta 8080;
* não expõe diretamente a porta 8080 para o host.

Isso segue a exigência do desafio de que o serviço não seja diretamente exposto ao host.

## NGINX

O NGINX utiliza a imagem oficial e possui a porta:

```text
80:80
```

O arquivo de configuração é montado através de volume:

```text
nginx/http-server-projeto-korp.conf
```

---

# 5. Proxy reverso

O NGINX funciona como proxy reverso entre o host e a aplicação.

Fluxo:

```text
localhost:80
      │
      ▼
    NGINX
      │
      ▼
http-server-projeto-korp:8080
```

O arquivo:

```text
nginx/http-server-projeto-korp.conf
```

configura o encaminhamento das requisições para a aplicação.

Dessa forma, o acesso externo é:

```bash
curl http://localhost:80/projeto-korp
```

Resultado esperado:

```json
{
  "nome": "Projeto Korp",
  "horario": "2026-08-15T02:24:05Z"
}
```

Esse teste corresponde ao teste de funcionamento especificado no desafio.

---

# 6. Monitoramento e Observabilidade

A segunda etapa adiciona monitoramento ao serviço `http-server-projeto-korp`.

As duas métricas obrigatórias são:

* disponibilidade do serviço;
* volume de requisições.

As métricas são expostas utilizando o padrão do Prometheus, conforme solicitado no desafio.

---

## 6.1 Endpoint de métricas

A aplicação expõe métricas no endpoint:

```text
/metrics
```

Exemplo:

```bash
curl http://172.18.0.2:8080/metrics
```

Entre as métricas disponibilizadas estão:

```text
http_server_up
http_server_requests_total
```

Além das métricas específicas da aplicação, a aplicação Golang também expõe métricas do runtime e do processo.

---

# 7. Disponibilidade

A disponibilidade da aplicação é representada pela métrica:

```text
http_server_up
```

Valores:

```text
1 = serviço disponível
0 = serviço indisponível
```

Exemplo:

```text
http_server_up 1
```

No Grafana, essa métrica é apresentada visualmente como:

```text
UP
```

ou:

```text
DOWN
```

Isso permite identificar rapidamente se o serviço está disponível.

---

# 8. Volume de requisições

O volume de requisições é acompanhado através da métrica:

```text
http_server_requests_total
```

Ela registra a quantidade de requisições recebidas pelo serviço.

A métrica possui informações como:

```text
endpoint
method
status
```

Exemplo:

```text
http_server_requests_total{
    endpoint="/projeto-korp",
    method="GET",
    status="200"
}
```

Também é possível utilizar PromQL para analisar a taxa de requisições ao longo do tempo.

Exemplo:

```promql
rate(http_server_requests_total[5m])
```

---

# 9. Prometheus

O Prometheus é responsável por coletar as métricas disponibilizadas pela aplicação.

O arquivo:

```text
prometheus.yml
```

define a configuração de coleta.

Fluxo:

```text
http-server-projeto-korp
          │
          │ /metrics
          ▼
      Prometheus
```

O Prometheus foi configurado para realizar o scrape do serviço da aplicação.

---

# 10. Grafana

O Grafana é utilizado para visualizar as métricas coletadas pelo Prometheus.

O ambiente possui configuração de provisionamento para:

* datasource do Prometheus;
* dashboard;
* configuração do dashboard.

Arquivos:

```text
files/grafana/provisioning/datasources/datasources.yml
```

```text
files/grafana/provisioning/dashboards/dashboard.yml
```

```text
files/grafana/dashboards/http-server-projeto-korp-dashboard.json
```

O desafio permite que o dashboard seja criado manualmente, porém a automatização através de arquivos de provisioning é considerada um bônus. Neste projeto, o provisioning foi implementado para tornar a configuração reproduzível.

---

# 11. Dashboard

O dashboard do Projeto Korp permite acompanhar o comportamento da aplicação.

Entre as informações apresentadas estão:

### Disponibilidade

```text
Status da Aplicação
```

Representação:

```text
UP
DOWN
```

### Volume de requisições

A métrica:

```text
http_server_requests_total
```

permite acompanhar a quantidade e a taxa de requisições recebidas.

### CPU

Monitoramento do consumo de CPU do processo.

### Memória

Monitoramento da memória utilizada pela aplicação.

### Goroutines

Quantidade de goroutines utilizadas pelo processo Go.

### Memória do runtime Go

Monitoramento de informações relacionadas ao heap da aplicação.

### Garbage Collection

Monitoramento das informações de Garbage Collection do runtime Go.

### Status dos targets

Monitoramento do estado dos targets acompanhados pelo Prometheus.

---

# 12. Automação com Ansible

A terceira etapa do desafio consiste em automatizar todo o ambiente utilizando Ansible.

O arquivo principal é:

```text
playbook.yml
```

O playbook foi desenvolvido para realizar o provisionamento do ambiente Linux.

Entre as etapas automatizadas estão:

1. instalação/configuração do Docker;
2. criação da rede Docker;
3. preparação da aplicação;
4. build da imagem;
5. configuração do NGINX;
6. configuração do proxy reverso;
7. configuração do Prometheus;
8. configuração do Grafana;
9. execução dos containers;
10. validação do serviço através de uma requisição HTTP.

Esses pontos correspondem aos requisitos mínimos estabelecidos para o playbook.

---

# 13. Provisionamento do ambiente

Depois de configurar o inventário:

```text
inventory.ini
```

o ambiente pode ser provisionado através do Ansible.

Exemplo:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

A ideia é que o ambiente completo seja configurado através de um único comando Ansible, conforme solicitado no desafio.

---

# 14. Validação

Após o provisionamento, o funcionamento do serviço pode ser validado com:

```bash
curl http://localhost:80/projeto-korp
```

Resposta esperada:

```json
{
  "horario": "2026-08-15T02:24:05Z",
  "nome": "Projeto Korp"
}
```

Também é possível verificar diretamente as métricas:

```bash
curl http://<IP_DO_CONTAINER>:8080/metrics
```

Exemplo de métricas específicas:

```text
http_server_up 1

http_server_requests_total{
    endpoint="/projeto-korp",
    method="GET",
    status="200"
}
```

---

# 15. Terraform — infraestrutura adicional

Além dos requisitos do desafio, foi utilizado Terraform para provisionar a infraestrutura AWS onde o projeto é executado.

Essa parte não substitui o Ansible.

A separação de responsabilidades é:

```text
Terraform
   │
   ├── Infraestrutura AWS
   ├── VPC
   ├── Subnet
   ├── Security Group
   ├── EC2
   └── Elastic IP
          │
          ▼
       Ansible
          │
          ├── Docker
          ├── Containers
          ├── NGINX
          ├── Prometheus
          └── Grafana
```

Dessa forma:

**Terraform = infraestrutura**

**Ansible = configuração e aplicação**

---

# 16. Estrutura Terraform

Os principais arquivos são:

```text
terraform/
├── ansible.tf
├── ec2.tf
├── main.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── security.tf
├── terraform.tfvars.example
├── variables.tf
└── versions.tf
```

O arquivo:

```text
terraform.tfvars
```

contém valores específicos do ambiente e não deve ser enviado para o GitHub.

Foi disponibilizado:

```text
terraform.tfvars.example
```

como modelo.

---

# 17. Inicializando o Terraform

Entre no diretório:

```bash
cd terraform
```

Inicialize o Terraform:

```bash
terraform init
```

Valide a configuração:

```bash
terraform validate
```

Visualize o plano:

```bash
terraform plan
```

Aplique a infraestrutura:

```bash
terraform apply
```

---

# 18. Cuidados com o Elastic IP

O projeto utiliza Elastic IP.

Antes de executar um `terraform destroy`, é importante considerar o estado desse recurso.

Caso o Elastic IP precise ser preservado, ele pode ser removido do state antes do destroy:

```bash
terraform state rm aws_eip.korp
```

Depois:

```bash
terraform destroy
```

Após recriar a infraestrutura:

```bash
terraform import aws_eip.korp eipalloc-XXXXXXXX
```

E então:

```bash
terraform apply
```

O `eipalloc-XXXXXXXX` deve ser substituído pelo ID real do Elastic IP.

**Importante:** o procedimento acima deve ser utilizado somente quando o Elastic IP realmente precisa ser preservado. O state do Terraform e os recursos AWS devem ser tratados com cuidado para evitar alterações ou exclusões acidentais.

---

# 19. Segurança

Arquivos contendo informações específicas do ambiente não devem ser enviados para o repositório.

O `.gitignore` impede o versionamento de arquivos como:

```text
*.pem
*.key
.env
*.tfvars
*.tfstate
*.tfstate.*
```

O projeto disponibiliza apenas o exemplo:

```text
terraform.tfvars.example
```

Isso permite que outra pessoa configure seus próprios valores sem expor informações do ambiente original.

---

# 20. Execução completa

A sequência geral para reproduzir o projeto é:

```text
1. Provisionar infraestrutura
          │
          ▼
      Terraform
          │
          ▼
2. Criar máquina Linux
          │
          ▼
3. Executar Ansible
          │
          ▼
4. Instalar/configurar Docker
          │
          ▼
5. Criar rede Docker
          │
          ▼
6. Build da aplicação
          │
          ▼
7. Subir Docker Compose
          │
          ├──────────────┐
          ▼              ▼
        NGINX        Aplicação Go
          │              │
          │              └── /metrics
          │                    │
          ▼                    ▼
       HTTP :80          Prometheus
                              │
                              ▼
                           Grafana
```

---

# 21. Testes principais

## Teste da aplicação através do NGINX

```bash
curl -i http://localhost:80/projeto-korp
```

Esperado:

```text
HTTP/1.1 200 OK
```

e o JSON da aplicação.

---

## Teste da porta 8080

A porta 8080 não deve estar diretamente exposta ao host.

Por isso:

```bash
curl http://localhost:8080/projeto-korp
```

pode falhar.

Isso é esperado, pois o acesso externo deve ocorrer através do NGINX:

```text
localhost:80
     │
     ▼
   NGINX
     │
     ▼
app:8080
```

---

## Teste das métricas

```bash
curl http://<IP_INTERNO_DA_APLICACAO>:8080/metrics
```

Verificar principalmente:

```text
http_server_up
```

e:

```text
http_server_requests_total
```

---

## Teste do Docker

```bash
docker ps
```

Verificar se os containers estão em execução.

Também pode ser utilizado:

```bash
docker network ls
```

para verificar a rede Docker.

---

# 22. Tecnologias utilizadas

| Tecnologia     | Função                                |
| -------------- | ------------------------------------- |
| Go             | Desenvolvimento do serviço HTTP       |
| Docker         | Conteinerização                       |
| Docker Compose | Orquestração dos containers           |
| NGINX          | Proxy reverso                         |
| Prometheus     | Coleta de métricas                    |
| Grafana        | Visualização das métricas             |
| Ansible        | Automação e provisionamento           |
| Terraform      | Provisionamento da infraestrutura AWS |
| AWS EC2        | Servidor Linux                        |
| AWS VPC        | Rede da infraestrutura                |
| Git/GitHub     | Versionamento do projeto              |

---

# 23. Resultado final

O projeto final permite:

* executar uma aplicação HTTP em Golang;
* executar a aplicação dentro de um container;
* utilizar uma rede Docker para comunicação entre serviços;
* utilizar NGINX como proxy reverso;
* acessar a aplicação através da porta 80;
* expor métricas no padrão Prometheus;
* monitorar a disponibilidade da aplicação;
* monitorar o volume de requisições;
* coletar métricas com Prometheus;
* visualizar métricas através do Grafana;
* utilizar dashboard para análise do comportamento da aplicação;
* provisionar o ambiente automaticamente com Ansible;
* provisionar a infraestrutura AWS com Terraform.

A implementação atende aos requisitos técnicos principais do desafio e também inclui automação do Grafana através de provisioning, além do provisionamento adicional da infraestrutura com Terraform.

---

# 24. Demonstração

Durante a demonstração do projeto, a sequência recomendada é:

### 1. Mostrar o código da aplicação

```text
app/main.go
```

Explicar:

* servidor HTTP;
* porta 8080;
* endpoint `/projeto-korp`;
* horário UTC;
* métricas Prometheus.

### 2. Mostrar o Dockerfile

```text
app/Dockerfile
```

Explicar a construção e execução da aplicação em container.

### 3. Mostrar o Docker Compose

```text
docker-compose.yml
```

Explicar:

* rede;
* aplicação;
* NGINX;
* Prometheus;
* Grafana;
* volumes;
* portas.

### 4. Mostrar o proxy reverso

```text
nginx/http-server-projeto-korp.conf
```

Explicar o fluxo:

```text
HTTP :80 → NGINX → aplicação :8080
```

### 5. Testar a aplicação

```bash
curl http://localhost:80/projeto-korp
```

### 6. Mostrar as métricas

```bash
curl http://<IP>:8080/metrics
```

Mostrar principalmente:

```text
http_server_up
http_server_requests_total
```

### 7. Mostrar o Prometheus

Demonstrar que o target está sendo coletado.

### 8. Mostrar o Grafana

Apresentar o dashboard e destacar:

```text
Disponibilidade do serviço
Volume de requisições
```

Além das métricas adicionais.

### 9. Demonstrar o Ansible

Executar:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

Mostrar a execução e a validação final realizada pelo playbook.

### 10. Mostrar o Terraform

Apresentar a infraestrutura AWS e explicar a separação:

```text
Terraform → infraestrutura
Ansible   → configuração da máquina e aplicação
```

---

# 25. Considerações finais

O projeto foi desenvolvido com foco em automação, reprodutibilidade e observabilidade.

A aplicação é executada de forma isolada em container, o NGINX controla o acesso externo, o Prometheus coleta as métricas e o Grafana fornece a visualização.

O Ansible automatiza a configuração do ambiente e o Terraform permite reproduzir a infraestrutura AWS.

O resultado é uma arquitetura simples, reproduzível e alinhada aos requisitos apresentados no desafio técnico da Korp.
