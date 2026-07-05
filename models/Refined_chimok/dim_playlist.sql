{{ 
  config(
    materialized='table',
    alias='dim_playlist'
  ) 
}}

WITH source_data AS (

    SELECT * FROM {{ ref('tru_playlist') }} -- Certifique-se que o nome do modelo na Trusted seja tru_playlist

),

transformed AS (

    SELECT
        -- Surrogate Key e Natural Key
        sk_playlist,
        playlist_id AS nk_playlist_id,

        -- Limpeza e Padronização
        -- Garante que nomes de playlists não tenham espaços extras e estejam em formato de título
        TRIM(playlist_name) AS nome_playlist,
        
        -- SCD Type 2 e Auditoria
        data_de,
        data_ate,
        fl_ultima_versao,
        load_date

    FROM source_data
    WHERE playlist_id IS NOT NULL

)

SELECT * FROM transformed