{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Customer') }}
),
renamed AS (
    SELECT
        CAST(CustomerId AS INT)         AS customer_id,
        CAST(FirstName AS VARCHAR(100)) AS first_name,
        CAST(LastName AS VARCHAR(100))  AS last_name,
        CAST(Company AS VARCHAR(255))   AS company,
        CAST(Address AS VARCHAR(255))   AS address,
        CAST(City AS VARCHAR(100))      AS city,
        CAST(State AS VARCHAR(100))     AS state,
        CAST(Country AS VARCHAR(100))   AS country,
        CAST(PostalCode AS VARCHAR(100)) AS postal_code,
        CAST(Phone AS VARCHAR(100))      AS phone,
        CAST(Fax AS VARCHAR(50))        AS fax,
        CAST(Email AS VARCHAR(255))     AS email,
        CAST(SupportRepId AS INT)       AS support_rep_id
        -- Chave técnica (recomendado)
        ,(HASHBYTES('SHA2_256', 
                    CONCAT(CustomerId,'|',SupportRepId))) AS HashKey
        -- Colunas de Controle / Auditoria
        ,GETDATE()                       AS LoadDate
        ,'Origem_Chimok'                 AS SourceSystem
    FROM source
)
SELECT * FROM renamed