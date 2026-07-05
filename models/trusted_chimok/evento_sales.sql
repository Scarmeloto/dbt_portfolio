{{ config(
    materialized='incremental',
    unique_key='invoice_line_id',
    on_schema_change='append_new_columns'
) }}

WITH base_data AS (

    SELECT

        CONVERT(VARCHAR(8), CAST(a.invoice_date  AS DATETIME), 112) AS sk_invoice_date,
        a.invoice_id,
        a.customer_id,
        c.sk_cliente,

        b.invoice_line_id,

        b.track_id,
        e.sk_produto,

        d.employee_id,
        d.sk_funcionario,

        f.playlist_id,
        f.sk_playlist,

        b.unit_price,
        b.quantity,
        b.line_total,
        a.total_amount,

        GETDATE() AS load_date

    FROM "Stage_Chimok"."stg"."stg_invoice" a

    LEFT JOIN "Stage_Chimok"."stg"."stg_invoice_line" b
        ON a.invoice_id = b.invoice_id

    LEFT JOIN "Trusted_Chimok"."tru"."tru_customer" c
        ON a.customer_id = c.customer_id

    LEFT JOIN "Trusted_Chimok"."tru"."tru_employee" d
        ON c.support_rep_id = d.employee_id

    LEFT JOIN "Trusted_Chimok"."tru"."tru_product" e
        ON b.track_id = e.track_id

    LEFT JOIN "Trusted_Chimok"."tru"."tru_playlist" f
        ON e.playlist_id = f.playlist_id

)

SELECT *

FROM base_data

{% if is_incremental() %}
    WHERE invoice_line_id NOT IN (SELECT invoice_line_id FROM {{ this }})
{% endif %}