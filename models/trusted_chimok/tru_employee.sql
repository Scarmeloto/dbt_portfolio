{{ config(
    materialized='incremental',
    unique_key='sk_funcionario',
    database='Trusted_Chimok',
    schema='tru'
) }}

WITH employee AS (

    SELECT
        employee_id,
        first_name,
        last_name,
        job_title,
        city,
        state,
        email
    FROM "Stage_Chimok"."stg"."stg_employee"

),

support AS (

    SELECT
        employee_id,
        first_name,
        last_name,
        job_title,
        city,
        state,
        email
    FROM "Stage_Chimok"."stg"."stg_support_staff"

),

base_data AS (

    SELECT * FROM employee
    UNION ALL
    SELECT * FROM support

)

SELECT

    -- Surrogate Key (Hash)
    CONVERT(
        VARCHAR(64),
        HASHBYTES(
            'SHA2_256',
            CONCAT(
                employee_id, '|',
                first_name, '|',
                last_name, '|',
                job_title, '|',
                city, '|',
                state, '|',
                email
            )
        ),
    2) AS sk_funcionario,

    employee_id,
    first_name,
    last_name,
    job_title,
    city,
    state,
    email,

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
                employee_id, '|',
                GETDATE()
            )
        ),
    2) AS HashKey

FROM base_data