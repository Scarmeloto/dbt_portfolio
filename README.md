# Projeto: Analytics Engineering - Pipeline de Dados (Chimok & Música)

Este projeto centraliza e transforma dados transacionais e de streaming utilizando a filosofia **Modern Data Stack** (dbt + SQL Server). O foco é transformar dados brutos em inteligência analítica, com foco especial no ecossistema do **Projeto Música**.

## 🏗️ Arquitetura Medalhão
Adotamos a arquitetura em camadas para garantir governança e reusabilidade:

* **Bronze (Origem):** Dados brutos de suporte e catálogo musical.
* **Silver (Staging/Trusted):** Camada de limpeza e padronização (TRIM, tipos, nomenclaturas).
* **Gold (Refined):** Camada de negócio, com dados agregados para BI.


---
## 🎵 O Projeto Música
O objetivo central é consolidar a jornada do usuário com o conteúdo musical.
* **Objetivo:** Analisar o comportamento de consumo (streams), a performance do catálogo e a interação dos usuários com as plataformas de música.
* **Dimensões Principais:**
    * `dim_musicas`: Atributos de faixas (artista, gênero, duração, álbum).
    * `dim_usuarios`: Perfil do ouvinte (plano, região, data de cadastro).
    * `dim_tempo`: Hierarquia de calendário (dia, mês, ano, trimestre).
* **Principais Indicadores (KPIs):**
    * **Total de Streams:** Volume total de reproduções por período.
    * **Taxa de Retenção:** Usuários ativos que consomem conteúdo recorrentemente.
    * **Engajamento por Gênero:** Qual estilo musical gera maior tempo médio de audição.
    * **Churn Rate:** Usuários que cessaram o consumo de conteúdo.

---

## 🚀 Transformações e Processamento
* **Pipeline:** Paradigma **ELT** com dbt.
* **Staging:** Granularidade 1:1, injeção de metadados (`load_date`, `dbt_batch_id`) e padronização.
* **Incrementalidade:** Uso de `incremental` com `pre_hook` (TRUNCATE) para garantir atualizações rápidas sem perder índices ou permissões.

## 💡 Boas Práticas implementadas no dbt
1.  **Configuração Centralizada:** Gerenciamento de esquemas (`stg`, `trusted`, `refined`) via `dbt_project.yml`.
2.  **Rastreabilidade:** Auditoria total com `dbt_batch_id` em todos os modelos.
3.  **Padronização:** Uso de macros (`generate_schema_name`) para organização estrita dos esquemas no SQL Server.
4.  **Sources:** Mapeamento centralizado de origens.

## 🛠️ Como rodar o projeto

1.  **Configuração:** Certifique-se de que o `profiles.yml` está conectado ao servidor `DIESS`.
2.  **Instalação:** Rode `dbt deps`.
3.  **Execução:**
    ```bash
    # Executa a carga com limpeza prévia
    dbt run --full-refresh
    
    # Validação de integridade
    dbt test
    ```
4.  **Documentação:**
    ```bash
    dbt docs generate
    dbt docs serve
    ```