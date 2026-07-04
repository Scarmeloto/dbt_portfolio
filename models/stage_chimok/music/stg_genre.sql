{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Genre') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(GenreId AS INT)             AS genre_id,
        
        -- Detalhes do Gênero
        CAST(Name AS VARCHAR(255))      AS genre_name,

        -- Chave técnica (Hash baseada no ID único do gênero)
        HASHBYTES('SHA2_256', CAST(GenreId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                        AS LoadDate,
        'Origem_Chimok'                  AS SourceSystem
    FROM source
)

SELECT * FROM renamed