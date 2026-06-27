{{ 
    config
    (
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'PURCHASE_ID',
        merge_exclude_columns = ['INSERT_DTS']
    )
}}

WITH purchase_src AS
(
    select
    PURCHASE_ID, 
    PURCHASE_DATE, 
    PURCHASE_STATUS, 
    CREATED_AT,
    CURRENT_TIMESTAMP AS INSERT_DTS,
    CURRENT_TIMESTAMP AS UPDATE_DTS
    from {{ source('purchase','PURCHASE_SRC')}}
    {% if is_incremental() %}
    where CREATED_AT > (select MAX(UPDATE_DTS) from {{this}})
    {% endif %}
)

select * from purchase_src