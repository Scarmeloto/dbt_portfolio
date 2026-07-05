{{ config(
    materialized='incremental',
    unique_key='sk_playlist',
    on_schema_change='append_new_columns',
    database='Trusted_Chimok',
    schema='tru'
) }}

WITH base_data AS (

    SELECT DISTINCT
        playlist_id,
        playlist_name,

    FROM "Stage_Chimok"."stg"."stg_playlist"

)

SELECT

    -- Surrogate Key (Hash)
    CONVERT(
        VARCHAR(64),
        HASHBYTES(
            'SHA2_256',
            CONCAT(
                playlist_id, '|',
                playlist_name
            )
        ),
    2) AS sk_playlist,

    playlist_id,
    playlist_name,

    GETDATE() AS data_de,
    CAST('99991231' AS DATETIME) AS data_ate,
    CAST(1 AS SMALLINT) AS fl_ultima_versao,

    GETDATE() AS load_date,

    -- Hash de controle (detecção de mudança)
    CONVERT(
        VARCHAR(64),
        HASHBYTES(
            'SHA2_256',
            CONCAT(
                playlist_id, '|',
                GETDATE()
            )
        ),
    2) AS HashKey

FROM base_data