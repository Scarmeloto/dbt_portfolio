{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Playlist') }}
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(PlaylistId AS INT)             AS playlist_id,
        
        -- Detalhes da Playlist
        CAST(Name AS VARCHAR(255))      AS playlist_name,

        -- Chave técnica (Hash baseada no ID único da playlist)
        HASHBYTES('SHA2_256', CAST(PlaylistId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                        AS LoadDate,
        'Origem_Chimok'                  AS SourceSystem
    FROM source
)

SELECT * FROM renamed