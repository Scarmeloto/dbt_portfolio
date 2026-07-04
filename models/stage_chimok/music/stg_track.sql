{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT a.*, b.PlaylistId FROM {{ source('Origem_Chimok', 'Track') }} a
    left join {{ source('Origem_Chimok', 'PlaylistTrack') }} b 
    on a.TrackId = b.TrackId
),

renamed AS (
    SELECT
        -- IDs e Chaves de negócio
        CAST(TrackId AS INT)             AS track_id,
        CAST(AlbumId AS INT)             AS album_id,
        CAST(MediaTypeId AS INT)         AS media_type_id,
        CAST(GenreId AS INT)             AS genre_id,
        CAST(PlaylistId AS INT)          AS playlist_id,

        -- Detalhes da Faixa
        CAST(Name AS VARCHAR(255))       AS track_name,
        CAST(Composer AS VARCHAR(255))   AS composer,
        CAST(Milliseconds AS INT)        AS duration_ms,
        CAST(Bytes AS INT)               AS file_size_bytes,
        CAST(UnitPrice AS DECIMAL(10,2)) AS unit_price,

        -- Chave técnica (Hash baseada no ID único da faixa)
        HASHBYTES('SHA2_256', CAST(TrackId AS VARCHAR(10))) AS HashKey,
        
        -- Colunas de Controle / Auditoria
        GETDATE()                        AS LoadDate,
        'Origem_Chimok'                  AS SourceSystem
    FROM source
)

SELECT * FROM renamed