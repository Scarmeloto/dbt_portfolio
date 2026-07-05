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

# 5. Dicionário de Dados – `fact_sales`

A tabela **fact_sales** representa a **tabela fato** do modelo dimensional, armazenando as transações de vendas consolidadas e servindo como principal fonte para consultas analíticas e dashboards.

---

## Estrutura da Tabela

| Coluna | Tipo | Descrição |
|:--------|:-----|:----------|
| **sk_invoice_date** | VARCHAR(10) | Chave substituta para a dimensão de tempo. |
| **invoice_id** | INT | Identificador único da nota fiscal. |
| **invoice_line_id** | INT | Identificador único da linha do item (grão da tabela). |
| **sk_cliente** | VARCHAR(64) | Chave substituta da dimensão Cliente. |
| **sk_produto** | VARCHAR(64) | Chave substituta da dimensão Produto (Música). |
| **sk_funcionario** | VARCHAR(64) | Chave substituta da dimensão Funcionário. |
| **sk_playlist** | VARCHAR(64) | Chave substituta da dimensão Playlist. |
| **unit_price** | DECIMAL(10,2) | Valor unitário da faixa. |
| **quantity** | INT | Quantidade de itens vendidos. |
| **line_total** | DECIMAL(10,2) | Valor total da linha (*Unit Price × Quantity*). |
| **total_amount** | DECIMAL(10,2) | Valor total da nota fiscal. |
| **load_date** | DATETIME | Data e hora da carga na camada Refined. |

---

## Granularidade

A granularidade da tabela é definida por **uma linha por item de nota fiscal**, permitindo análises detalhadas por:

- Cliente
- Produto (Música)
- Funcionário
- Playlist
- Data
- Valor da venda

---

## Chaves da Tabela

| Tipo | Colunas |
|------|---------|
| **Chave de Negócio** | `invoice_id` + `invoice_line_id` |
| **Chaves Estrangeiras** | `sk_invoice_date`, `sk_cliente`, `sk_produto`, `sk_funcionario`, `sk_playlist` |

---

# 6. Objetivos e Desafios

## Objetivo

Desenvolver um **pipeline moderno de Engenharia de Dados**, capaz de transformar dados operacionais em informações analíticas confiáveis, escaláveis e de alta disponibilidade para suporte à tomada de decisão.

---

## Objetivos Específicos

- Construir uma arquitetura em camadas (**Landing → Bronze → Silver → Gold/Refined**).
- Implementar processos de ETL/ELT utilizando **DBT**.
- Modelar os dados utilizando **Star Schema**.
- Garantir rastreabilidade e qualidade dos dados durante todo o pipeline.
- Disponibilizar uma camada otimizada para consumo por ferramentas de BI.

---

## Principais Desafios

| Desafio | Descrição |
|---------|-----------|
| **Padronização** | Uniformizar esquemas provenientes de diferentes fontes de dados. |
| **Escalabilidade** | Implementar cargas incrementais para reduzir tempo de processamento e consumo de recursos. |
| **Governança** | Garantir unicidade dos registros por meio de *Surrogate Keys* e regras de qualidade. |
| **Performance** | Otimizar consultas analíticas utilizando modelagem dimensional. |
| **Manutenibilidade** | Estruturar modelos modulares e reutilizáveis utilizando DBT. |

---

## Benefícios Esperados

- Maior confiabilidade dos dados.
- Redução do tempo de processamento.
- Facilidade para manutenção e evolução do pipeline.
- Alto desempenho em consultas analíticas.
- Dados preparados para dashboards e análises estratégicas.
- Arquitetura aderente às boas práticas de Engenharia de Dados.

## 7. Como Executar
1º Instale as dependências: dbt deps
2º Valide o projeto: dbt compile
3º Execute o pipeline: dbt run