-- models/staging/sales/stg_invoice_customer.sql

{{ config(
    materialized = 'incremental',
    schema = 'dbo',
    alias = 'stg_invoice_customer',
    pre_hook = "TRUNCATE TABLE {{ this }}"
) }}

WITH source AS (

    SELECT
         c.CustomerId
        ,c.FirstName      AS Customer_FirstName
        ,c.LastName       AS Customer_LastName
        ,c.Company        AS Customer_Company
        ,c.Address        AS Customer_Address
        ,c.City           AS Customer_City
        ,c.State          AS Customer_State
        ,c.Country        AS Customer_Country
        ,c.PostalCode     AS Customer_PostalCode
        ,c.Phone          AS Customer_Phone
        ,c.Fax            AS Customer_Fax
        ,c.Email          AS Customer_Email
        ,c.SupportRepId

        ,i.InvoiceId
        ,i.CustomerId         AS Invoice_CustomerId
        ,i.InvoiceDate        AS Invoice_InvoiceDate
        ,i.BillingAddress     AS Invoice_BillingAddress
        ,i.BillingCity        AS Invoice_BillingCity
        ,i.BillingState       AS Invoice_BillingState
        ,i.BillingCountry     AS Invoice_BillingCountry
        ,i.BillingPostalCode  AS Invoice_BillingPostalCode
        ,i.Total              AS Invoice_Total

    FROM {{ source('Origem_Chimok', 'Customer') }} c

    LEFT JOIN {{ source('Origem_Chimok', 'Invoice') }} i
        ON c.CustomerId = i.CustomerId

),

transformed AS (

    SELECT

        -- Chaves
         CustomerId            AS customer_id
        ,SupportRepId          AS support_rep_id
        ,InvoiceId             AS invoice_id
        ,Invoice_CustomerId    AS invoice_customer_id

        -- Customer
        ,TRIM(Customer_FirstName)   AS customer_first_name
        ,TRIM(Customer_LastName)    AS customer_last_name
        ,TRIM(Customer_Company)     AS customer_company
        ,TRIM(Customer_Address)     AS customer_address
        ,TRIM(Customer_City)        AS customer_city
        ,TRIM(Customer_State)       AS customer_state
        ,TRIM(Customer_Country)     AS customer_country
        ,TRIM(Customer_PostalCode)  AS customer_postal_code
        ,TRIM(Customer_Phone)       AS customer_phone
        ,TRIM(Customer_Fax)         AS customer_fax
        ,TRIM(Customer_Email)       AS customer_email

        -- Invoice
        ,Invoice_InvoiceDate            AS invoice_date
        ,TRIM(Invoice_BillingAddress)   AS billing_address
        ,TRIM(Invoice_BillingCity)      AS billing_city
        ,TRIM(Invoice_BillingState)     AS billing_state
        ,TRIM(Invoice_BillingCountry)   AS billing_country
        ,TRIM(Invoice_BillingPostalCode) AS billing_postal_code
        ,Invoice_Total                  AS invoice_total

        -- Metadados
        ,GETDATE()          AS load_date
        ,'stage_chimok'     AS source_system
        ,'{{ invocation_id }}' AS dbt_batch_id

    FROM source

)

SELECT *
FROM transformed