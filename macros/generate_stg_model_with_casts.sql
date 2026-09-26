{% macro generate_stg_model_with_casts(source_name, table_name) %}

    {%- set source_relation = source(source_name, table_name) -%}
    {%- set columns = adapter.get_columns_in_relation(source_relation) -%}

    {%- set sql -%}
with
    source as
        (select * from {{ source_relation }}),

    renamed as
        (select
            {%- for col in columns %}
            cast({{ col.name | lower }} as {{ col.data_type | lower }}) as {{ col.name | lower }}{%- if not loop.last -%},{%- endif -%} 
            {%- endfor %}
        from 
            source)
        
select * from renamed
    {%- endset -%}

    {%- if execute -%} {{ print(sql) }} {%- endif -%}

{% endmacro %}
