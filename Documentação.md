# Projeto de Analytics: Data Pipeline dbt

## 1. Visão Geral
Este projeto implementa uma arquitetura de dados *Medallion* (Staging, Trusted, Refined) utilizando **dbt (data build tool)**. O foco é garantir a integridade dos dados, rastreabilidade e performance analítica, transformando dados brutos em uma fonte única da verdade para suporte à tomada de decisão.

## 2. Modelo Relacional (Fonte de Dados)
O projeto processa dados transacionais estruturados conforme o modelo relacional abaixo:

![Modelo de Dados Relacional](https://github.com/Scarmeloto/dbt_portfolio/blob/main/Capturar.JPG)

## 3. Estrutura do Projeto
A organização do projeto segue a separação de responsabilidades para garantir governança e escalabilidade:

```text
models/
├── staging/
│   ├── customer/       # Ingestão de dados de clientes
│   ├── sales/          # Ingestão de transações de vendas
│   ├── support/        # Ingestão de dados de suporte
│   ├── music/          # Catálogo musical (track, album, etc)
│   └── reference/      # Tabelas de referência e domínios
├── trusted/            # Camada de negócio e qualidade
│   ├── dimensions/     # Entidades dedupicadas e limpas
│   ├── facts/          # Tabelas fato incrementais
│   └── marts/          # Agregações específicas de negócio
└── refined/            # Camada de consumo (Star Schema)
    └── fact_sales.sql  # Tabela fato centralizada

## 4. Matriz de Indicadores e Dimensões (Camada Refined)
A camada Refined organiza os dados no padrão Star Schema para otimização de queries analíticas.


| Entidade | Tipo | Indicadores / Atributos Chave |
| :--- | :---: | ---: |
| fact_sales | fato | Unit Price, Quantity, Line Total, Total Amount |
| dim_customer | Dimensão | Identificação, Geografia, LTV |
| dim_music | Dimensão | Título da faixa, Álbum, Artista, Gênero |
| dim_employee | Dimensão | Nome, Cargo, Data de Admissão |

## 5. Dicionário de Dados: fact_sales

Coluna,Tipo,Descrição
sk_invoice_date,VARCHAR(10),Chave substituta para dimensão tempo
invoice_id,INT,Identificador único da nota fiscal
invoice_line_id,INT,PK da linha de item (grânulo)
unit_price,DECIMAL,Preço unitário da faixa
line_total,DECIMAL,Total da linha (Preço * Quantidade)
total_amount,DECIMAL,Valor total da nota fiscal
load_date,DATETIME,Data e hora da carga