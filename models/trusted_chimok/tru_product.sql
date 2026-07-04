{{
  config(
    materialized='incremental',
    unique_key='sk_produto'
  )
}}

WITH base_data AS (
    SELECT DISTINCT
        b.artist_name,
        a.album_title,
        c.track_name,
        case when c.composer is null or c.composer = '' then 'Unknown' else c.composer end as composer,
        d.genre_name,
        e.media_type_name,
        c.track_id
    FROM {{ ref('stg_album') }} a
    INNER JOIN {{ ref('stg_artist') }} b ON a.artist_id = b.artist_id
    INNER JOIN {{ ref('stg_track') }} c ON a.album_id = c.album_id
    LEFT JOIN {{ ref('stg_genre') }} d ON c.genre_id = d.genre_id
    LEFT JOIN {{ ref('stg_media_type') }} e ON c.media_type_id = e.media_type_id
)

SELECT
    -- Usando CONVERT com estilo 2 para gerar HEXADECIMAL completo e evitar truncamento
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT(track_id, '|', artist_name, '|', album_title, '|', track_name)), 2) AS sk_produto,
    
    track_id,
    track_name,
    album_title,
    artist_name,
    genre_name,
    composer,
    media_type_name,
    
    GETDATE() AS data_de,
    CAST('99991231' AS DATETIME) AS data_ate,
    CAST(1 AS SMALLINT) AS fl_ultima_versao,
    
    GETDATE() AS load_date,
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT(track_id, '|', GETDATE())), 2) AS HashKey
FROM base_data

{% if is_incremental() %}
    WHERE track_id NOT IN (SELECT track_id FROM {{ this }})
{% endif %}