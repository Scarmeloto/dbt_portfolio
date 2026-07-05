{% macro generate_database_name(custom_database_name, node) -%}
    {{ custom_database_name if custom_database_name is not none else target.database }}
{%- endmacro %}

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is not none -%}
        {{ custom_schema_name }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}