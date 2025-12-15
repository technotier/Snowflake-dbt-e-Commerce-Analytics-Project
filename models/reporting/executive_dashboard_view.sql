with business_kpi_cte as (

    select
        dd.month_num,
        dd.month,

        count(distinct fs.order_id) as total_orders,
        sum(fs.net_amount) as total_revenue,
        sum(fs.net_profit_amount) as total_profit,
        sum(fs.quantity) as total_qty_sold,
        sum(fs.discounts) as total_discounts,

        round(
            sum(fs.net_amount) / nullif(count(distinct fs.order_id), 0), 
        2) as aov,

        round(
            sum(fs.net_profit_amount) * 100.0 / nullif(sum(fs.net_amount), 0), 
        2) as profit_percent,

        count(distinct case when fs.order_status = 'Completed' then fs.order_id end) as successful_orders,
        count(distinct case when fs.order_status = 'Pending' then fs.order_id end) as pending_orders,
        count(distinct case when fs.order_status = 'Returned' then fs.order_id end) as returned_orders,
        count(distinct case when fs.order_status = 'Cancelled' then fs.order_id end) as cancelled_orders,

        round(
            count(distinct case when fs.order_status = 'Cancelled' then fs.order_id end)
            * 100.0 / nullif(count(distinct fs.order_id), 0),
        2) as cancellation_rate,

        round(
            count(distinct case when fs.order_status in ('Completed','Pending') then fs.order_id end)
            * 100.0 / nullif(count(distinct fs.order_id), 0),
        2) as fulfillment_rate

    from {{ ref('fact_sales') }} fs
    join {{ ref('dim_date') }} dd
        on fs.order_date = dd.order_date

    group by 1, 2
),

growth_rate_cte as (

    select
        *,
        lag(total_orders) over(order by month_num) as prev_month_orders,
        lag(total_revenue) over(order by month_num) as prev_month_revenue,
        lag(total_profit) over(order by month_num) as prev_month_profit,
        lag(total_qty_sold) over(order by month_num) as prev_month_qty_sold,

        round(
            (total_revenue - prev_month_revenue) * 100.0
            / nullif(prev_month_revenue, 0),
        2) as mom_growth_rate,

        round(
            avg(total_revenue) over (
                order by month_num
                rows between 2 preceding and current row
            ),
        2) as moving_avg_3_months

    from business_kpi_cte
),

cumulative_cte as (

    select
        *,
        sum(total_orders) over(order by month_num) as cumulative_orders,
        sum(total_revenue) over(order by month_num) as cumulative_total,
        sum(total_profit) over(order by month_num) as cumulative_profit

    from growth_rate_cte
),

performance_indicators_cte as (

    select
        *,
        case 
            when mom_growth_rate > 15 then '🚀 Excellent Growth'
            when mom_growth_rate > 5  then '📈 Strong Growth'
            when mom_growth_rate > 0  then '👍 Positive Growth'
            when mom_growth_rate < 0  then '📉 Declining'
            else '➡️ Stable'
        end as growth_rate_status,

        case 
            when profit_percent > 30 then '💰 Excellent Margin'
            when profit_percent > 20 then '💵 Good Margin'
            when profit_percent > 10 then '💲 Fair Margin'
            else '⚠️ Low Margin'
        end as margin_status,

        case 
            when fulfillment_rate > 50 then '🎯 Excellent'
            when fulfillment_rate > 45 then '✅ Good'
            when fulfillment_rate > 40 then '⚠️ Needs Attention'
            else '❌ Poor'
        end as fulfillment_status

    from cumulative_cte
)

select
    *,
    case 
        when mom_growth_rate > 10 and profit_percent > 20 and fulfillment_rate > 50 then '🏆 Outstanding'
        when mom_growth_rate > 5  and profit_percent > 15 and fulfillment_rate > 45 then '⭐ Excellent'
        when mom_growth_rate > 0  and profit_percent > 10 and fulfillment_rate > 40 then '✅ Good'
        else '⚠️ Needs Improvement'
    end as overall_performance

from performance_indicators_cte
order by month_num
