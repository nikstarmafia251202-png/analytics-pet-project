-- Продажи по месяцам (исправлено)
-- SELECT 
--     DATE_TRUNC('month', o.order_date) AS month,
--     COUNT(DISTINCT o.order_id) AS orders_count,
--     SUM(oi.total_price) AS total_revenue,
--     AVG(oi.total_price) AS avg_order_value,
--     COUNT(DISTINCT o.user_id) AS unique_customers,
--     SUM(o.shipping_cost) AS total_shipping
-- FROM core.orders o
-- JOIN core.order_items oi ON o.order_id = oi.order_id
-- WHERE o.status = 'completed'
-- GROUP BY DATE_TRUNC('month', o.order_date)
-- ORDER BY month DESC;


-- Общая выручка (исправлено)
-- SELECT 
--     COUNT(DISTINCT o.order_id) AS total_orders,
--     SUM(oi.total_price) AS total_revenue,
--     AVG(oi.total_price) AS avg_order_value,
--     SUM(o.shipping_cost) AS total_shipping,
--     COUNT(DISTINCT o.user_id) AS unique_customers
-- FROM core.orders o
-- JOIN core.order_items oi ON o.order_id = oi.order_id
-- WHERE o.status = 'completed';


-- -- Статистика по статусам
-- SELECT 
--     status,
--     COUNT(*) AS orders_count,
--     SUM(oi.total_price) AS revenue,
--     AVG(oi.total_price) AS avg_value
-- FROM core.orders o
-- LEFT JOIN core.order_items oi ON o.order_id = oi.order_id
-- GROUP BY status
-- ORDER BY orders_count DESC;


-- Показать все поля всех таблиц
-- SELECT 
--     table_name,
--     column_name,
--     data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'core'
-- ORDER BY table_name, ordinal_position;



-- Общая сумма каждого заказа
-- SELECT 
--     o.order_id,
--     o.order_date,
--     o.status,
--     u.first_name || ' ' || u.last_name AS customer,
--     COALESCE(SUM(oi.total_price), 0) AS order_total,
--     o.shipping_cost,
--     COALESCE(SUM(oi.total_price), 0) + o.shipping_cost AS total_with_shipping
-- FROM core.orders o
-- JOIN core.users u ON o.user_id = u.user_id
-- LEFT JOIN core.order_items oi ON o.order_id = oi.order_id
-- GROUP BY o.order_id, o.order_date, o.status, u.first_name, u.last_name, o.shipping_cost
-- ORDER BY o.order_date DESC
-- LIMIT 20;

-- Топ-5 клиентов по выручке
-- SELECT 
--     u.user_id,
--     u.first_name || ' ' || u.last_name AS customer,
--     u.email,
--     u.city,
--     COUNT(DISTINCT o.order_id) AS orders_count,
--     SUM(oi.total_price) AS total_spent,
--     AVG(oi.total_price) AS avg_order_value
-- FROM core.users u
-- JOIN core.orders o ON u.user_id = o.user_id AND o.status = 'completed'
-- JOIN core.order_items oi ON o.order_id = oi.order_id
-- GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.city
-- ORDER BY total_spent DESC
-- LIMIT 5;


-- Товары с наибольшей выручкой
-- SELECT 
--     p.product_id,
--     p.product_name,
--     c.category_name,
--     COUNT(DISTINCT oi.order_id) AS orders_count,
--     SUM(oi.quantity) AS total_sold,
--     SUM(oi.total_price) AS revenue,
--     AVG(r.rating) AS avg_rating
-- FROM core.products p
-- JOIN core.categories c ON p.category_id = c.category_id
-- LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
-- LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
-- LEFT JOIN core.reviews r ON p.product_id = r.product_id
-- GROUP BY p.product_id, p.product_name, c.category_name
-- ORDER BY revenue DESC NULLS LAST
-- LIMIT 10;


-- ==========================================
-- 1. ОБЩАЯ СТАТИСТИКА ПО БАЗЕ
-- ==========================================

-- Сколько всего записей в каждой таблице?
-- SELECT 'users' AS table_name, COUNT(*) AS rows_count FROM core.users
-- UNION ALL
-- SELECT 'categories', COUNT(*) FROM core.categories
-- UNION ALL
-- SELECT 'products', COUNT(*) FROM core.products
-- UNION ALL
-- SELECT 'orders', COUNT(*) FROM core.orders
-- UNION ALL
-- SELECT 'order_items', COUNT(*) FROM core.order_items
-- UNION ALL
-- SELECT 'reviews', COUNT(*) FROM core.reviews
-- UNION ALL
-- SELECT 'promocodes', COUNT(*) FROM core.promocodes
-- ORDER BY rows_count DESC;

-- ==========================================
-- 2. АНАЛИЗ ЗАКАЗОВ
-- ==========================================

-- 2.1. Распределение заказов по статусам
-- SELECT 
--     status,
--     COUNT(*) AS orders_count,
--     ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
-- FROM core.orders
-- GROUP BY status
-- ORDER BY orders_count DESC;

-- -- 2.2. Распределение по методам оплаты
-- SELECT 
--     payment_method,
--     COUNT(*) AS orders_count,
--     ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
-- FROM core.orders
-- GROUP BY payment_method
-- ORDER BY orders_count DESC;

-- -- 2.3. Заказы по месяцам (все заказы, включая отмененные)
-- SELECT 
--     DATE_TRUNC('month', order_date) AS month,
--     COUNT(*) AS total_orders,
--     SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
--     SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
-- FROM core.orders
-- GROUP BY DATE_TRUNC('month', order_date)
-- ORDER BY month;


-- ==========================================
-- 3. ФИНАНСОВЫЙ АНАЛИЗ
-- ==========================================

-- 3.1. Общая выручка и метрики
-- SELECT 
--     COUNT(DISTINCT o.order_id) AS completed_orders,
--     COUNT(DISTINCT o.user_id) AS unique_customers,
--     SUM(oi.total_price) AS total_revenue,
--     ROUND(AVG(oi.total_price), 2) AS avg_order_value,
--     SUM(o.shipping_cost) AS total_shipping,
--     ROUND(AVG(o.shipping_cost), 2) AS avg_shipping,
--     ROUND(SUM(oi.total_price) / NULLIF(COUNT(DISTINCT o.user_id), 0), 2) AS revenue_per_customer
-- FROM core.orders o
-- JOIN core.order_items oi ON o.order_id = oi.order_id
-- WHERE o.status = 'completed';

-- -- 3.2. Динамика выручки по месяцам (только выполненные заказы)
-- SELECT 
--     DATE_TRUNC('month', o.order_date) AS month,
--     COUNT(DISTINCT o.order_id) AS orders_count,
--     SUM(oi.total_price) AS revenue,
--     ROUND(AVG(oi.total_price), 2) AS avg_order_value,
--     SUM(oi.quantity) AS items_sold,
--     SUM(o.shipping_cost) AS shipping_cost
-- FROM core.orders o
-- JOIN core.order_items oi ON o.order_id = oi.order_id
-- WHERE o.status = 'completed'
-- GROUP BY DATE_TRUNC('month', o.order_date)
-- ORDER BY month;

-- -- 3.3. Топ-10 заказов по сумме
-- SELECT 
--     o.order_id,
--     o.order_date,
--     u.first_name || ' ' || u.last_name AS customer,
--     u.email,
--     COUNT(oi.order_item_id) AS items_count,
--     SUM(oi.total_price) AS order_total,
--     o.shipping_cost,
--     SUM(oi.total_price) + o.shipping_cost AS total_with_shipping
-- FROM core.orders o
-- JOIN core.users u ON o.user_id = u.user_id
-- JOIN core.order_items oi ON o.order_id = oi.order_id
-- WHERE o.status = 'completed'
-- GROUP BY o.order_id, o.order_date, u.first_name, u.last_name, u.email, o.shipping_cost
-- ORDER BY order_total DESC
-- LIMIT 10;


-- ==========================================
-- 4. ТОВАРНЫЙ АНАЛИЗ
-- ==========================================

-- 4.1. Топ-10 товаров по выручке
-- SELECT 
--     p.product_id,
--     p.product_name,
--     c.category_name,
--     p.price AS current_price,
--     COUNT(DISTINCT oi.order_id) AS orders_count,
--     SUM(oi.quantity) AS total_sold,
--     SUM(oi.total_price) AS revenue,
--     ROUND(AVG(r.rating), 2) AS avg_rating,
--     COUNT(DISTINCT r.review_id) AS reviews_count
-- FROM core.products p
-- JOIN core.categories c ON p.category_id = c.category_id
-- LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
-- LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
-- LEFT JOIN core.reviews r ON p.product_id = r.product_id
-- GROUP BY p.product_id, p.product_name, c.category_name, p.price
-- HAVING SUM(oi.total_price) IS NOT NULL
-- ORDER BY revenue DESC
-- LIMIT 10;

-- -- 4.2. Топ-10 товаров по количеству продаж
-- SELECT 
--     p.product_id,
--     p.product_name,
--     c.category_name,
--     SUM(oi.quantity) AS total_sold,
--     SUM(oi.total_price) AS revenue,
--     COUNT(DISTINCT oi.order_id) AS orders_count
-- FROM core.products p
-- JOIN core.categories c ON p.category_id = c.category_id
-- JOIN core.order_items oi ON p.product_id = oi.product_id
-- JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
-- GROUP BY p.product_id, p.product_name, c.category_name
-- ORDER BY total_sold DESC
-- LIMIT 10;

-- -- 4.3. Анализ по категориям
-- SELECT 
--     c.category_name,
--     COUNT(DISTINCT p.product_id) AS products_count,
--     COUNT(DISTINCT oi.order_id) AS orders_count,
--     SUM(oi.quantity) AS items_sold,
--     SUM(oi.total_price) AS revenue,
--     ROUND(AVG(oi.total_price), 2) AS avg_price,
--     ROUND(AVG(r.rating), 2) AS avg_rating,
--     ROUND(100.0 * SUM(oi.total_price) / SUM(SUM(oi.total_price)) OVER (), 2) AS revenue_share
-- FROM core.categories c
-- LEFT JOIN core.products p ON c.category_id = p.category_id
-- LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
-- LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
-- LEFT JOIN core.reviews r ON p.product_id = r.product_id
-- GROUP BY c.category_name
-- ORDER BY revenue DESC NULLS LAST;


-- ==========================================
-- 5. КЛИЕНТСКИЙ АНАЛИЗ (ИСПРАВЛЕННЫЙ)
-- ==========================================

-- 5.1. Распределение клиентов по городам
-- SELECT 
--     city,
--     COUNT(*) AS customers_count,
--     ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
-- FROM core.users
-- GROUP BY city
-- ORDER BY customers_count DESC;

-- -- 5.2. Распределение по возрасту
-- SELECT 
--     CASE 
--         WHEN age < 25 THEN '18-24'
--         WHEN age < 35 THEN '25-34'
--         WHEN age < 45 THEN '35-44'
--         WHEN age < 55 THEN '45-54'
--         ELSE '55+'
--     END AS age_group,
--     COUNT(*) AS customers_count,
--     ROUND(AVG(age), 1) AS avg_age
-- FROM core.users
-- GROUP BY age_group
-- ORDER BY age_group;

-- -- 5.3. Топ-10 клиентов по сумме покупок (ИСПРАВЛЕНО)
-- SELECT 
--     u.user_id,
--     u.first_name || ' ' || u.last_name AS customer,
--     u.email,
--     u.city,
--     u.age,
--     COUNT(DISTINCT o.order_id) AS orders_count,
--     COALESCE(SUM(oi.total_price), 0) AS total_spent,
--     COALESCE(ROUND(AVG(oi.total_price), 2), 0) AS avg_order_value,
--     MAX(o.order_date) AS last_order_date,
--     COALESCE(CURRENT_DATE - MAX(o.order_date), 0) AS days_since_last_order
-- FROM core.users u
-- LEFT JOIN core.orders o ON u.user_id = o.user_id AND o.status = 'completed'
-- LEFT JOIN core.order_items oi ON o.order_id = oi.order_id
-- GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.city, u.age
-- HAVING COALESCE(SUM(oi.total_price), 0) > 0
-- ORDER BY total_spent DESC
-- LIMIT 10;

-- -- 5.4. Сегментация клиентов (RFM-анализ) (ИСПРАВЛЕНО)
-- WITH customer_metrics AS (
--     SELECT 
--         u.user_id,
--         u.first_name || ' ' || u.last_name AS customer,
--         COUNT(DISTINCT o.order_id) AS orders_count,
--         COALESCE(SUM(oi.total_price), 0) AS total_spent,
--         COALESCE(MAX(o.order_date), u.registration_date) AS last_order_date,
--         COALESCE(
--             CURRENT_DATE - COALESCE(MAX(o.order_date), u.registration_date), 
--             0
--         ) AS days_since_last
--     FROM core.users u
--     LEFT JOIN core.orders o ON u.user_id = o.user_id AND o.status = 'completed'
--     LEFT JOIN core.order_items oi ON o.order_id = oi.order_id
--     GROUP BY u.user_id, u.first_name, u.last_name, u.registration_date
-- )
-- SELECT 
--     CASE 
--         WHEN orders_count = 0 THEN 'Неактивные'
--         WHEN orders_count >= 5 AND total_spent > 50000 THEN 'VIP'
--         WHEN orders_count >= 3 THEN 'Активные'
--         WHEN days_since_last > 60 THEN 'Возвращающиеся'
--         ELSE 'Новые'
--     END AS segment,
--     COUNT(*) AS customers_count,
--     ROUND(AVG(total_spent), 2) AS avg_spent,
--     ROUND(AVG(orders_count), 2) AS avg_orders,
--     ROUND(AVG(days_since_last), 1) AS avg_days_inactive
-- FROM customer_metrics
-- GROUP BY segment
-- ORDER BY avg_spent DESC;


-- ==========================================
-- 6. АНАЛИЗ ОТЗЫВОВ
-- ==========================================

-- 6.1. Распределение оценок
-- SELECT 
--     rating,
--     COUNT(*) AS reviews_count,
--     ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
-- FROM core.reviews
-- GROUP BY rating
-- ORDER BY rating DESC;

-- -- 6.2. Средний рейтинг по товарам
-- SELECT 
--     p.product_name,
--     c.category_name,
--     COUNT(r.review_id) AS reviews_count,
--     ROUND(AVG(r.rating), 2) AS avg_rating,
--     MIN(r.rating) AS min_rating,
--     MAX(r.rating) AS max_rating
-- FROM core.products p
-- JOIN core.categories c ON p.category_id = c.category_id
-- LEFT JOIN core.reviews r ON p.product_id = r.product_id
-- GROUP BY p.product_name, c.category_name
-- HAVING COUNT(r.review_id) > 0
-- ORDER BY avg_rating DESC;

-- -- 6.3. Связь рейтинга с продажами
-- SELECT 
--     p.product_name,
--     ROUND(AVG(r.rating), 2) AS avg_rating,
--     COUNT(DISTINCT r.review_id) AS reviews_count,
--     SUM(oi.quantity) AS total_sold,
--     SUM(oi.total_price) AS revenue
-- FROM core.products p
-- LEFT JOIN core.reviews r ON p.product_id = r.product_id
-- LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
-- LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
-- GROUP BY p.product_name
-- HAVING COUNT(DISTINCT r.review_id) > 0
-- ORDER BY avg_rating DESC;


-- ==========================================
-- СОЗДАНИЕ ПРЕДСТАВЛЕНИЙ ДЛЯ АНАЛИТИКИ
-- ==========================================

-- 1. Создаем схему analytics (если еще нет)
CREATE SCHEMA IF NOT EXISTS analytics;

-- 2. Представление: Статистика по категориям
CREATE OR REPLACE VIEW analytics.category_stats AS
SELECT 
    c.category_id,
    c.category_name,
    COUNT(DISTINCT p.product_id) AS products_count,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    COALESCE(SUM(oi.quantity), 0) AS items_sold,
    COALESCE(SUM(oi.total_price), 0) AS total_revenue,
    COALESCE(ROUND(AVG(oi.total_price), 2), 0) AS avg_item_price,
    COALESCE(ROUND(AVG(r.rating), 2), 0) AS avg_rating
FROM core.categories c
LEFT JOIN core.products p ON c.category_id = p.category_id
LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
LEFT JOIN core.reviews r ON p.product_id = r.product_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

-- 3. Представление: Топ-10 товаров
CREATE OR REPLACE VIEW analytics.top_products AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    COUNT(DISTINCT oi.order_id) AS order_count,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    COALESCE(SUM(oi.total_price), 0) AS revenue,
    COALESCE(ROUND(AVG(r.rating), 2), 0) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS reviews_count,
    ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(oi.total_price), 0) DESC) AS rank
FROM core.products p
JOIN core.categories c ON p.category_id = c.category_id
LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
LEFT JOIN core.reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, c.category_name
HAVING COALESCE(SUM(oi.total_price), 0) > 0
ORDER BY revenue DESC
LIMIT 10;

-- 4. Представление: Ежедневные продажи
CREATE OR REPLACE VIEW analytics.daily_sales AS
SELECT 
    o.order_date,
    COUNT(DISTINCT o.order_id) AS orders_count,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    COUNT(oi.order_item_id) AS items_sold,
    SUM(oi.quantity) AS total_quantity,
    COALESCE(SUM(oi.total_price), 0) AS revenue,
    COALESCE(SUM(o.shipping_cost), 0) AS total_shipping,
    COALESCE(ROUND(AVG(oi.total_price), 2), 0) AS avg_order_value
FROM core.orders o
JOIN core.order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY o.order_date
ORDER BY o.order_date DESC;

-- 5. Проверка созданных представлений
SELECT '✅ Представления созданы!' AS status;


-- ==========================================
-- 7. СВОДНЫЙ ОТЧЕТ ДЛЯ ДАШБОРДА (БЕЗ ПРЕДСТАВЛЕНИЙ)
-- ==========================================

-- ==========================================
-- 7. СВОДНЫЙ ОТЧЕТ ДЛЯ ДАШБОРДА (БЕЗ ПРЕДСТАВЛЕНИЙ)
-- ==========================================

WITH 
-- 1. Основные метрики
metrics AS (
    SELECT 
        (SELECT COUNT(*) FROM core.users) AS total_users,
        (SELECT COUNT(*) FROM core.orders WHERE status = 'completed') AS completed_orders,
        (SELECT COUNT(*) FROM core.products) AS total_products,
        (SELECT COUNT(*) FROM core.reviews) AS total_reviews,
        (SELECT COALESCE(ROUND(SUM(total_price), 2), 0) 
         FROM core.order_items oi
         JOIN core.orders o ON oi.order_id = o.order_id
         WHERE o.status = 'completed') AS total_revenue
),

-- 2. Средний чек
avg_order AS (
    SELECT COALESCE(ROUND(AVG(order_total), 2), 0) AS avg_order_value
    FROM (
        SELECT o.order_id, COALESCE(SUM(oi.total_price), 0) AS order_total
        FROM core.orders o
        JOIN core.order_items oi ON o.order_id = oi.order_id
        WHERE o.status = 'completed'
        GROUP BY o.order_id
    ) t
),

-- 3. Топ категория
top_category AS (
    SELECT 
        c.category_name,
        COALESCE(SUM(oi.total_price), 0) AS total_revenue
    FROM core.categories c
    LEFT JOIN core.products p ON c.category_id = p.category_id
    LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
    LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
    GROUP BY c.category_name
    ORDER BY total_revenue DESC
    LIMIT 1
),

-- 4. Топ товар
top_product AS (
    SELECT 
        p.product_name,
        COALESCE(SUM(oi.total_price), 0) AS revenue
    FROM core.products p
    LEFT JOIN core.order_items oi ON p.product_id = oi.product_id
    LEFT JOIN core.orders o ON oi.order_id = o.order_id AND o.status = 'completed'
    GROUP BY p.product_name
    ORDER BY revenue DESC
    LIMIT 1
)

-- 5. Финальный отчет
SELECT 
    m.total_users,
    m.completed_orders,
    m.total_products,
    m.total_reviews,
    m.total_revenue,
    a.avg_order_value,
    tc.category_name AS top_category,
    tc.total_revenue AS top_category_revenue,
    tp.product_name AS top_product,
    tp.revenue AS top_product_revenue
FROM metrics m, avg_order a, top_category tc, top_product tp;
