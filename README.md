# Infraestrutura AWS com Terraform

Este repositório contém a definição da infraestrutura AWS usando o Terraform para configurar uma aplicação containerizada com ECS, uma rede VPC privada, um repositório ECR, um balanceador de carga ALB, um cluster ElastiCache Redis, entre outros recursos.

[Desenho da arquitetura](https://drive.google.com/file/d/12gofNmXk8W2QnhxiFWCI4OmvVH6Vsgun/view?usp=drive_link)

## Pré-requisitos

- Conta AWS configurada
- Terraform instalado localmente
- Chave de acesso AWS configurada localmente

## Arquitetura

A arquitetura da infraestrutura consiste nos seguintes componentes:

- **ECR Repository**: Repositório para armazenar imagens Docker.
- **VPC e Subnets**: Rede privada com três subnets em diferentes zonas de disponibilidade.
- **Internet Gateway e Route Table**: Gateway e tabela de roteamento para permitir acesso à internet.
- **Security Group**: Grupo de segurança para controlar o tráfego de entrada e saída.
- **ECS Cluster**: Cluster ECS para executar os containers.
- **Launch Template**: Modelo de lançamento para configurar instâncias EC2 no cluster ECS.
- **Auto Scaling Group**: Grupo de escalabilidade automática para gerenciar instâncias EC2.
- **Capacity Providers**: Provedores de capacidade para gerenciar a capacidade do cluster ECS.
- **Load Balancer**: Balanceador de carga para distribuir o tráfego para os containers.
- **ElastiCache Redis Cluster**: Cluster ElastiCache Redis para armazenamento em cache.

## Como Usar

1. Clone este repositório em sua máquina local.
2. Configure suas credenciais AWS.
3. Personalize as variáveis no arquivo `variables.tf` conforme necessário.
4. Execute `terraform init` para inicializar o diretório.
5. Execute `terraform plan` para visualizar as alterações propostas.
6. Execute `terraform apply` para aplicar as alterações e criar a infraestrutura.

## Limpeza

Para evitar custos indesejados, é recomendável remover a infraestrutura quando não estiver mais em uso. Execute `terraform destroy` para remover todos os recursos criados por este script.

**Observação:** A remoção da infraestrutura é irreversível e resultará na perda de dados armazenados nos serviços da AWS.
