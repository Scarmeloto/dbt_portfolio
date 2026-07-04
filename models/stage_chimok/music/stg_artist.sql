{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Artist') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(ArtistId AS INT)             AS artist_id,
        
        -- Detalhes do Artista
        CAST(Name AS VARCHAR(255))      AS artist_name,

        -- Chave técnica (Hash baseada no ID único do artista)
        HASHBYTES('SHA2_256', CAST(ArtistId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                        AS LoadDate,
        'Origem_Chimok'                  AS SourceSystem
    FROM source
)

SELECT * FROM renamed