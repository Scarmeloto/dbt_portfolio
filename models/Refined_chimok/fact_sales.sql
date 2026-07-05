{{ 
  config(
    materialized='incremental',
    unique_key='invoice_line_id',
    alias='fact_sales'
  ) 
}}

WITH source_trusted AS (
    -- Seleciona os dados da camada Trusted
    SELECT * FROM {{ ref('evento_sales') }} 
),

final_fact AS (
    SELECT
        -- Atributos de Data e Chaves de Negócio
        CAST(sk_invoice_date AS VARCHAR(10)) AS sk_invoice_date,
        CAST(invoice_id AS INT) AS invoice_id,
        CAST(customer_id AS INT) AS customer_id,
        CAST(invoice_line_id AS INT) AS invoice_line_id,
        CAST(track_id AS INT) AS track_id,
        CAST(employee_id AS INT) AS employee_id,
        CAST(playlist_id AS INT) AS playlist_id,

        -- Métricas Financeiras
        CAST(unit_price AS DECIMAL(18, 2)) AS unit_price,
        CAST(quantity AS INT) AS quantity,
        CAST(line_total AS DECIMAL(18, 2)) AS line_total,
        CAST(total_amount AS DECIMAL(18, 2)) AS total_amount,

        -- Auditoria
        CAST(load_date AS DATETIME) AS load_date,

        -- Surrogate Keys (Chaves Substitutas para o Star Schema)
        CAST(sk_cliente AS VARCHAR(200)) AS sk_cliente,
        CAST(sk_produto AS VARCHAR(200)) AS sk_produto,
        CAST(sk_funcionario AS VARCHAR(200)) AS sk_funcionario,
        CAST(sk_playlist AS VARCHAR(200)) AS sk_playlist
    FROM source_trusted
)

SELECT * FROM final_fact

{% if is_incremental() %}
    -- Apenas novos registros
    WHERE invoice_line_id NOT IN (SELECT invoice_line_id FROM {{ this }})
{% endif %}