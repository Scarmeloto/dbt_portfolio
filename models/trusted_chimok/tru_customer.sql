{{ config(
    materialized='incremental',
    unique_key='sk_cliente',
    on_schema_change='append_new_columns'
) }}

WITH base_data AS (

    SELECT DISTINCT
        customer_id,
        first_name,
        last_name,
        CASE 
            WHEN company IS NULL OR company = '' THEN 'Unknown'
            ELSE company 
        END AS company,
        city,
        state,
        email,
        support_rep_id
    FROM {{ ref('stg_customer') }} 

)

SELECT

    -- Surrogate Key (Hash)
    CONVERT(
        VARCHAR(64),
        HASHBYTES(
            'SHA2_256',
            CONCAT(
                customer_id, '|',
                first_name, '|',
                last_name, '|',
                company, '|',
                city, '|',
                state, '|',
                email
            )
        ),
    2) AS sk_cliente,

    customer_id,
    first_name,
    last_name,
    company,
    city,
    state,
    email,
    support_rep_id,
    
    GETDATE() AS data_de,
    CAST('99991231' AS DATETIME) AS data_ate,
    CAST(1 AS SMALLINT) AS fl_ultima_versao,

    GETDATE() AS load_date,

    -- Hash de controle (mudança de registro)
    CONVERT(
        VARCHAR(64),
        HASHBYTES(
            'SHA2_256',
            CONCAT(
                customer_id, '|',
                GETDATE()
            )
        ),
    2) AS HashKey

FROM base_data