-- models/staging/support/stg_support_staff.sql

{{ config(
    materialized = 'incremental',
    schema = 'dbo',
    alias = 'stg_support_staff',
    pre_hook = "TRUNCATE TABLE {{ this }}"
) }}


WITH source AS (
    SELECT 
         e.EmployeeId
         ,e.LastName   as Employee_LastName
         ,e.FirstName  as Employee_FirstName
         ,e.Title      as Employee_Title
         ,e.ReportsTo  as Employee_ReportsTo
         ,e.BirthDate  as Employee_BirthDate
         ,e.HireDate   as Employee_HireDate
         ,e.Address    as Employee_Address
         ,e.City       as Employee_City
         ,e.State      as Employee_State
         ,e.Country    as Employee_Country
         ,e.PostalCode as Employee_PostalCode
         ,e.Phone      as Employee_Phone
         ,e.Fax        as Employee_Fax
         ,e.Email      as Employee_Email
         ,c.CustomerId
         ,c.FirstName  as Customer_FirstName
         ,c.LastName   as Customer_LastName
         ,c.Company    as Customer_Company
         ,c.Address    as Customer_Address
         ,c.City       as Customer_City
         ,c.State      as Customer_State
         ,c.Country    as Customer_Country
         ,c.PostalCode as Customer_PostalCode
         ,c.Phone      as Customer_Phone
         ,c.Fax        as Customer_Fax
         ,c.Email      as Customer_Email
         ,c.SupportRepId
    FROM {{ source('Origem_Chimok', 'Employee') }} e
	LEFT JOIN {{ source('Origem_Chimok', 'Customer') }}c 
		ON e.EmployeeId = c.SupportRepId
),

transformed AS (
    SELECT
        -- Chaves
        EmployeeId                 AS employee_id
        ,SupportRepId              AS support_rep_id
        ,CustomerId                AS customer_id
        
        -- Employee
        ,TRIM(Employee_FirstName)  AS employee_first_name
        ,TRIM(Employee_LastName)   AS employee_last_name
        ,TRIM(Employee_Title)      AS employee_title
        ,Employee_ReportsTo  AS employee_reports_to
        
        ,Employee_BirthDate		AS employee_birth_date
        ,Employee_HireDate		AS employee_hire_date
        
        ,TRIM(Employee_Address)    AS employee_address
        ,TRIM(Employee_City)       AS employee_city
        ,TRIM(Employee_State)      AS employee_state
        ,TRIM(Employee_Country)    AS employee_country
        ,TRIM(Employee_PostalCode) AS employee_postal_code
        ,TRIM(Employee_Phone)      AS employee_phone
        ,TRIM(Employee_Fax)        AS employee_fax
        ,TRIM(Employee_Email)      AS employee_email
        
        -- Customer
        ,TRIM(Customer_FirstName)  AS customer_first_name
        ,TRIM(Customer_LastName)   AS customer_last_name
        ,TRIM(Customer_Company)    AS customer_company
        ,TRIM(Customer_Address)    AS customer_address
        ,TRIM(Customer_City)       AS customer_city
        ,TRIM(Customer_State)      AS customer_state
        ,TRIM(Customer_Country)    AS customer_country
        ,TRIM(Customer_PostalCode) AS customer_postal_code
        ,TRIM(Customer_Phone)      AS customer_phone
        ,TRIM(Customer_Fax)        AS customer_fax
        ,TRIM(Customer_Email)      AS customer_email
        
        -- Metadados
        ,GETDATE()                 AS load_date,
        'stage_chimok'            AS source_system,
        '{{ invocation_id }}'     AS dbt_batch_id
    FROM source
)
SELECT * 
FROM transformed