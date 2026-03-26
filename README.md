DNM
# Overview
This project analyzes the Brazilian E-Commerce Public Dataset by Olist to evaluate marketplace performance, understand customer purchasing behavior, and identify key revenue drivers. The goal is to translate raw transactional data into business insights that can support growth, category prioritization, and customer strategy.

The dataset covers the period from 2016 to 2018, a time when Brazil experienced economic and political instability. In a competitive e-commerce environment, understanding where revenue comes from and which customers and product categories contribute most is essential for making better business decisions.

---

## Dataset Context
Olist is a Brazilian e-commerce platform that enables small and medium-sized sellers to distribute products across multiple online marketplaces through a single integration. In addition to marketplace access, Olist also supports logistics and fulfillment operations.

Because Olist operates as a multi-seller marketplace, business performance depends not only on total sales, but also on category mix, customer value, seller contribution, and order fulfillment quality. This project focuses on analyzing these dimensions to uncover growth patterns and potential business opportunities.

---

## Business Questions
The analysis aims to answer the following business questions:

1. How has revenue changed over time from 2016 to 2018?
2. Is revenue growth driven mainly by order volume or average order value?
3. Which product categories contribute the most to total revenue, and how concentrated is revenue across categories?
4. Which customer groups generate the highest revenue and purchasing value?
5. Are there meaningful differences in revenue trends across product categories and customer segments?
6. What patterns in the data can help explain business growth opportunities and potential risks?

---

## Analysis Approach

The analysis begins with overall revenue performance to understand the business trend over time. It then breaks revenue down into key drivers such as order volume and average order value. After that, the analysis drills down into product categories, customers, and sellers to identify the main contributors to business performance. Finally, findings are translated into actionable insights and business recommendations.

## Analysis Assumptions
- Valid orders are defined as orders excluding 'canceled' and 'unavailable' statuses.
- Overall revenue is measured using 'payment_value' aggregated at the order level.
- Product and seller contribution analysis uses item-level revenue approximated by 'price + freight_value'.
- Time-based analysis is primarily performed at the monthly level because yearly coverage in the dataset is uneven.










