{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source_customer AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Customer') }}
),

source_invoice AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Invoice') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(i.InvoiceId AS INT)           AS invoice_id,
        CAST(c.CustomerId AS INT)          AS customer_id,
        
        -- Informações do Cliente/Fatura
        CAST(c.FirstName AS VARCHAR(100))           AS first_name,
        CAST(c.LastName AS VARCHAR(100))            AS last_name,
        CAST(i.InvoiceDate AS DATETIME)             AS invoice_date,
        CAST(i.BillingAddress AS VARCHAR(255))      AS billing_address,
        CAST(i.BillingCity AS VARCHAR(100))         AS billing_city,
        CAST(i.BillingCountry AS VARCHAR(100))      AS billing_country,
        CAST(i.BillingPostalCode AS VARCHAR(100))   AS billing_postal_code,
        CAST(i.Total AS DECIMAL(10,2))              AS total_amount,

        -- Chave técnica (baseada na combinação dos IDs de origem)
        HASHBYTES('SHA2_256', 
                  CONCAT(i.InvoiceId, '|', c.CustomerId)) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                          AS LoadDate,
        'Origem_Chimok'                    AS SourceSystem
    FROM source_invoice i
    JOIN source_customer c ON i.CustomerId = c.CustomerId
)

SELECT * FROM renamed