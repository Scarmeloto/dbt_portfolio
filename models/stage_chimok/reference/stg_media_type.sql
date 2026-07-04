{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'MediaType') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(MediaTypeId AS INT)             AS media_type_id,
        
        -- Detalhes do Tipo de Mídia
        CAST(Name AS VARCHAR(255))      AS media_type_name,

        -- Chave técnica (Hash baseada no ID único do tipo de mídia)
        HASHBYTES('SHA2_256', CAST(MediaTypeId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                        AS LoadDate,
        'Origem_Chimok'                  AS SourceSystem
    FROM source
)

SELECT * FROM renamed