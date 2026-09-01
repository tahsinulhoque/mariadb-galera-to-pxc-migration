USE migration_db;

INSERT INTO users (id, name, email)
VALUES
(1, 'Rahim Ahmed', 'rahim@example.com'),
(2, 'Karim Hasan', 'karim@example.com'),
(3, 'Nusrat Jahan', 'nusrat@example.com'),
(4, 'Sakib Khan', 'sakib@example.com'),
(5, 'Mim Akter', 'mim@example.com');

INSERT INTO products (id, name, price, stock)
VALUES
(1, 'Laptop', 75000.00, 10),
(2, 'Mechanical Keyboard', 4500.00, 25),
(3, 'Wireless Mouse', 1800.00, 40),
(4, 'Monitor', 25000.00, 15),
(5, 'USB-C Hub', 3200.00, 30);

INSERT INTO orders (id, user_id, status)
VALUES
(1, 1, 'completed'),
(2, 2, 'pending'),
(3, 3, 'completed'),
(4, 4, 'processing');

INSERT INTO order_items (id, order_id, product_id, quantity)
VALUES
(1, 1, 1, 1),
(2, 1, 3, 2),
(3, 2, 2, 1),
(4, 3, 4, 1),
(5, 4, 5, 2);