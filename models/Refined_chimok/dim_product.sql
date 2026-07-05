{{ 
  config(
    materialized='table',
    alias='dim_product'
  ) 
}}

WITH source_data AS (

    SELECT * FROM {{ ref('tru_product') }} -- Certifique-se que o nome do arquivo da trusted seja 'tru_product'

),

transformed AS (

    SELECT
        -- Surrogate Key e Chaves de Negócio
        sk_produto,
        track_id AS nk_track_id,
        playlist_id AS nk_playlist_id,

        -- Atributos do Produto (Transformações de Limpeza)
        UPPER(TRIM(track_name)) AS nome_faixa,
        UPPER(TRIM(album_title)) AS nome_album,
        UPPER(TRIM(artist_name)) AS nome_artista,
        COALESCE(UPPER(TRIM(composer)), 'NÃO INFORMADO') AS compositor,
        COALESCE(UPPER(TRIM(genre_name)), 'OUTROS') AS genero,
        COALESCE(UPPER(TRIM(media_type_name)), 'NÃO DEFINIDO') AS tipo_midia,

        -- Controle de Versão (SCD Type 2)
        data_de,
        data_ate,
        fl_ultima_versao,
        
        -- Auditoria
        load_date

    FROM source_data

)

SELECT * FROM transformed