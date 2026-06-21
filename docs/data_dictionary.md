Словарь данных (Data Dictionary)



\## Схема: core



\---



\### 📋 Таблица users (Пользователи)



Хранит информацию о клиентах интернет-магазина.



| Поле | Тип | Ограничения | Описание |

|------|-----|-------------|----------|

| user\_id | SERIAL | PRIMARY KEY | Уникальный ID пользователя |

| email | VARCHAR(255) | NOT NULL, UNIQUE | Адрес электронной почты |

| first\_name | VARCHAR(100) | | Имя |

| last\_name | VARCHAR(100) | | Фамилия |

| registration\_date | DATE | DEFAULT CURRENT\_DATE | Дата регистрации |

| city | VARCHAR(100) | | Город проживания |

| age | INTEGER | CHECK (0-120) | Возраст |

| gender | CHAR(1) | CHECK (M/F/O) | Пол (Мужской/Женский/Другое) |

| is\_active | BOOLEAN | DEFAULT TRUE | Активен ли пользователь |

| last\_activity\_date | DATE | DEFAULT CURRENT\_DATE | Дата последней активности |



\*\*Связи:\*\*

\- `user\_id` → `orders.user\_id` (один ко многим)

\- `user\_id` → `reviews.user\_id` (один ко многим)



\---



\### 📋 Таблица categories (Категории)



Хранит категории товаров (иерархическая структура).



| Поле | Тип | Ограничения | Описание |

|------|-----|-------------|----------|

| category\_id | SERIAL | PRIMARY KEY | Уникальный ID категории |

| category\_name | VARCHAR(100) | NOT NULL, UNIQUE | Название категории |

| parent\_category\_id | INTEGER | FK → categories | ID родительской категории |



\*\*Связи:\*\*

\- `category\_id` → `products.category\_id` (один ко многим)

\- `parent\_category\_id` → `categories.category\_id` (самореференция)



\---



\### 📋 Таблица products (Товары)



Хранит информацию о товарах.



| Поле | Тип | Ограничения | Описание |

|------|-----|-------------|----------|

| product\_id | SERIAL | PRIMARY KEY | Уникальный ID товара |

| product\_name | VARCHAR(255) | NOT NULL | Название товара |

| category\_id | INTEGER | FK → categories | ID категории |

| price | DECIMAL(10,2) | NOT NULL, CHECK (>=0) | Цена продажи |

| cost | DECIMAL(10,2) | CHECK (>=0) | Себестоимость |

| weight\_kg | DECIMAL(8,2) | | Вес в килограммах |

| created\_date | DATE | DEFAULT CURRENT\_DATE | Дата добавления |

| is\_available | BOOLEAN | DEFAULT TRUE | Доступен ли товар |



\*\*Связи:\*\*

\- `product\_id` → `order\_items.product\_id` (один ко многим)

\- `product\_id` → `reviews.product\_id` (один ко многим)



\---



\### 📋 Таблица orders (Заказы)



Хранит информацию о заказах.



| Поле | Тип | Ограничения | Описание |

|------|-----|-------------|----------|

| order\_id | SERIAL | PRIMARY KEY | Уникальный ID заказа |

| user\_id | INTEGER | FK → users | ID покупателя |

| order\_date | DATE | DEFAULT CURRENT\_DATE | Дата заказа |

| status | VARCHAR(50) | CHECK | Статус заказа |

| payment\_method | VARCHAR(50) | CHECK | Метод оплаты |

| delivery\_address | TEXT | | Адрес доставки |

| shipping\_cost | DECIMAL(10,2) | DEFAULT 0 | Стоимость доставки |



\*\*Статусы:\*\* `completed`, `cancelled`, `pending`, `refunded`

\*\*Методы оплаты:\*\* `card`, `cash`, `online`, `crypto`



\*\*Связи:\*\*

\- `order\_id` → `order\_items.order\_id` (один ко многим)

\- `order\_id` → `reviews.order\_id` (один ко многим)



\---



\### 📋 Таблица order\_items (Позиции заказов)



Хранит детали каждого заказа.



| Поле | Тип | Ограничения | Описание |

|------|-----|-------------|----------|

| order\_item\_id | SERIAL | PRIMARY KEY | Уникальный ID позиции |

| order\_id | INTEGER | FK → orders | ID заказа |

| product\_id | INTEGER | FK → products | ID товара |

| quantity | INTEGER | NOT NULL, CHECK (>0) | Количество |

| price\_at\_time | DECIMAL(10,2) | NOT NULL | Цена в момент заказа |

| discount\_percent | DECIMAL(5,2) | DEFAULT 0 | Скидка в процентах |

| total\_price | DECIMAL(10,2) | GENERATED | Общая стоимость (авто) |



\*\*total\_price\*\* вычисляется как: `price\_at\_time \* quantity \* (1 - discount\_percent/100)`



\---



\### 📋 Таблица reviews (Отзывы)



Хранит отзывы пользователей на товары.



| Поле | Тип | Ограничения | Описание |

|------|-----|-------------|----------|

| review\_id | SERIAL | PRIMARY KEY | Уникальный ID отзыва |

| user\_id | INTEGER | FK → users | ID автора |

| product\_id | INTEGER | FK → products | ID товара |

| order\_id | INTEGER | FK → orders | ID заказа |

| rating | INTEGER | CHECK (1-5) | Оценка (1-5) |

| review\_text | TEXT | | Текст отзыва |

| review\_date | DATE | DEFAULT CURRENT\_DATE | Дата отзыва |

| is\_verified | BOOLEAN | DEFAULT FALSE | Подтвержденный отзыв |



\---



\### 📋 Таблица promocodes (Промокоды)



Хранит информацию о промокодах.



| Поле | Тип | Ограничения | Описание |

|------|-----|-------------|----------|

| promo\_id | SERIAL | PRIMARY KEY | Уникальный ID |

| promo\_code | VARCHAR(50) | NOT NULL, UNIQUE | Код промокода |

| discount\_percent | INTEGER | CHECK (0-100) | Скидка в процентах |

| valid\_from | DATE | NOT NULL | Дата начала действия |

| valid\_to | DATE | NOT NULL | Дата окончания действия |

| usage\_limit | INTEGER | DEFAULT 100 | Лимит использований |

| used\_count | INTEGER | DEFAULT 0 | Количество использований |



\---



\## 📊 Статистика по таблицам



| Таблица | Количество записей |

|---------|-------------------|

| users | 25 |

| categories | 10 |

| products | 12 |

| orders | 530 |

| order\_items | 1002 |

| reviews | 556 |

| promocodes | 5 |

