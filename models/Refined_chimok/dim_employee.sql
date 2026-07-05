{{ config(
    materialized='table',
    alias='dim_employee',
    tags=['refined', 'dimensions'],
    database='Refined_Chimok',
    schema='gld'
) }}

WITH source_data AS (

    SELECT * FROM {{ ref('tru_employee') }} -- Nome do modelo da sua camada Trusted

),

transformed AS (

    SELECT
        -- Chaves e IDs
        sk_funcionario,
        employee_id AS nk_funcionario, -- Natural Key para rastreabilidade

        -- Limpeza e Padronização
        UPPER(TRIM(first_name)) AS nome,
        UPPER(TRIM(last_name)) AS sobrenome,
        CONCAT(UPPER(TRIM(first_name)), ' ', UPPER(TRIM(last_name))) AS nome_completo,
        
        -- Tratamento de nulos/vazios e padronização de cargo
        COALESCE(UPPER(TRIM(job_title)), 'NÃO INFORMADO') AS cargo,
        
        -- Padronização de localização
        UPPER(TRIM(city)) AS cidade,
        UPPER(TRIM(state)) AS estado,
        
        -- Validação de contato
        LOWER(TRIM(email)) AS email,
        
        -- SCD Type 2 Columns
        data_de,
        data_ate,
        fl_ultima_versao,
        
        -- Auditoria
        load_date

    FROM source_data
    WHERE employee_id IS NOT NULL

)

SELECT * FROM transformed