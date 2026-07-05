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

A camada **Refined** organiza os dados em um modelo **Star Schema**, estruturando fatos e dimensões para otimizar consultas analíticas, simplificar o consumo dos dados e melhorar o desempenho das ferramentas de BI.

### Estrutura das Entidades

| Entidade | Tipo | Indicadores / Atributos Principais |
|:---------|:-----|:----------------------------------|
| **fact_sales** | **Fato** | Unit Price, Quantity, Line Total, Total Amount |
| **dim_customer** | **Dimensão** | Identificação do Cliente, Cidade, Estado, País, LTV |
| **dim_music** | **Dimensão** | Track ID, Título da Faixa, Álbum, Artista, Gênero |
| **dim_employee** | **Dimensão** | Nome, Cargo, Data de Admissão |
| **dim_playlist** | **Dimensão** | Playlist, Quantidade de Faixas |

---

### Papel de cada entidade

| Entidade | Descrição |
|-----------|-----------|
| **fact_sales** | Armazena as transações de vendas e seus indicadores quantitativos. |
| **dim_customer** | Contém informações cadastrais e geográficas dos clientes. |
| **dim_music** | Reúne os atributos relacionados às músicas comercializadas. |
| **dim_employee** | Identifica o colaborador responsável pela venda. |
| **dim_playlist** | Disponibiliza informações sobre as playlists associadas às músicas. |

---

### Indicadores (Measures)

| Indicador | Descrição |
|-----------|-----------|
| **Unit Price** | Valor unitário da música. |
| **Quantity** | Quantidade vendida. |
| **Line Total** | Valor total do item da venda. |
| **Total Amount** | Valor total da fatura. |

---

### Relacionamentos do Star Schema

| Tabela Fato | Dimensão Relacionada | Chave |
|-------------|----------------------|--------|
| fact_sales | dim_customer | sk_cliente |
| fact_sales | dim_music | sk_produto |
| fact_sales | dim_employee | sk_funcionario |
| fact_sales | dim_playlist | sk_playlist |

> **Objetivo da Camada Refined:** disponibilizar dados tratados, padronizados e modelados em formato dimensional (**Star Schema**), proporcionando alta performance para análises, dashboards e consumo por ferramentas de Business Intelligence.