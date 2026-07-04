{{ config(
    materialized='table',
    database='Stage_Chimok',
    schema='stg'
) }}

WITH source AS (
    SELECT * FROM {{ source('Origem_Chimok', 'Employee') }}
),

renamed AS (
    SELECT
        -- Identificação
        CAST(EmployeeId AS INT)             AS employee_id,
        
        -- Nomes e Cargos
        CAST(FirstName AS VARCHAR(100))     AS first_name,
        CAST(LastName AS VARCHAR(100))      AS last_name,
        CAST(Title AS VARCHAR(100))         AS job_title,
        CAST(ReportsTo AS INT)              AS reports_to_id,
        
        -- Datas
        CAST(BirthDate AS DATETIME)         AS birth_date,
        CAST(HireDate AS DATETIME)          AS hire_date,
        
        -- Contato e Localização
        CAST(Address AS VARCHAR(255))       AS address,
        CAST(City AS VARCHAR(100))          AS city,
        CAST(State AS VARCHAR(100))         AS state,
        CAST(Country AS VARCHAR(100))       AS country,
        CAST(PostalCode AS VARCHAR(100))    AS postal_code,
        CAST(Phone AS VARCHAR(100))         AS phone,
        CAST(Fax AS VARCHAR(50))            AS fax,
        CAST(Email AS VARCHAR(255))         AS email,
        
        -- Chave técnica
        HASHBYTES('SHA2_256', CAST(EmployeeId AS VARCHAR(10))) AS HashKey,
        
        -- Auditoria
        GETDATE()                           AS LoadDate,
        'Origem_Chimok'                     AS SourceSystem
    FROM source
    -- Filtra apenas funcionários de suporte (ajuste o critério conforme seu banco)
    WHERE Title LIKE '%Support%' OR Title LIKE '%Agent%'
)

SELECT * FROM renamed