{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Album') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(AlbumId AS INT)             AS album_id,
        CAST(ArtistId AS INT)            AS artist_id,
        
        -- Detalhes do Álbum
        CAST(Title AS VARCHAR(255))      AS album_title,

        -- Chave técnica (Hash baseada no ID único do álbum)
        HASHBYTES('SHA2_256', CAST(AlbumId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                        AS LoadDate,
        'Origem_Chimok'                  AS SourceSystem
    FROM source
)

SELECT * FROM renamed