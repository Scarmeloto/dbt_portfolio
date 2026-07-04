{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'InvoiceLine') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(InvoiceLineId AS INT)         AS invoice_line_id,
        CAST(InvoiceId AS INT)             AS invoice_id,
        CAST(TrackId AS INT)               AS track_id,
        
        -- Detalhes da Linha da Fatura
        CAST(UnitPrice AS DECIMAL(10,2))   AS unit_price,
        CAST(Quantity AS INT)              AS quantity,
        
        -- Cálculo de valor total da linha
        CAST(UnitPrice * Quantity AS DECIMAL(10,2)) AS line_total,

        -- Chave técnica (Hash baseada no ID único da linha da fatura)
        HASHBYTES('SHA2_256', CAST(InvoiceLineId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                          AS LoadDate,
        'Origem_Chimok'                    AS SourceSystem
    FROM source
)

SELECT * FROM renamed