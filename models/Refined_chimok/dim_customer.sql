{{ config(
    materialized='table',
    alias='dim_customer'
) }}

WITH source_data AS (

    SELECT * FROM {{ ref('tru_customer') }} -- Ajuste conforme o nome do seu arquivo na pasta 'trusted'

),

transformed AS (

    SELECT
        -- Chaves
        sk_cliente,
        customer_id AS nk_cliente,
        support_rep_id, -- FK técnica para uma futura dim_employee

        -- Informações de Perfil (Padronização)
        UPPER(TRIM(first_name)) AS nome,
        UPPER(TRIM(last_name)) AS sobrenome,
        CONCAT(UPPER(TRIM(first_name)), ' ', UPPER(TRIM(last_name))) AS nome_completo,
        
        -- Empresas e Localização
        UPPER(TRIM(company)) AS empresa,
        UPPER(TRIM(city)) AS cidade,
        UPPER(TRIM(state)) AS estado,
        
        -- Contato
        LOWER(TRIM(email)) AS email,
        
        -- SCD Type 2 e Auditoria
        data_de,
        data_ate,
        fl_ultima_versao,
        load_date

    FROM source_data

)

SELECT * FROM transformed