{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Invoice') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(InvoiceId AS INT)             AS invoice_id,
        CAST(CustomerId AS INT)            AS customer_id,
        
        -- Detalhes da Fatura
        CAST(InvoiceDate AS DATETIME)      AS invoice_date,
        CAST(BillingAddress AS VARCHAR(255)) AS billing_address,
        CAST(BillingCity AS VARCHAR(100))  AS billing_city,
        CAST(BillingState AS VARCHAR(100)) AS billing_state,
        CAST(BillingCountry AS VARCHAR(100)) AS billing_country,
        CAST(BillingPostalCode AS VARCHAR(100)) AS billing_postal_code,
        CAST(Total AS DECIMAL(10,2))       AS total_amount,

        -- Chave técnica (Hash baseada no ID único da fatura)
        HASHBYTES('SHA2_256', CAST(InvoiceId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                          AS LoadDate,
        'Origem_Chimok'                    AS SourceSystem
    FROM source
)
SELECT * FROM renamed