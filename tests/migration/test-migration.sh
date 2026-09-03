#!/bin/bash

echo "======================================"
echo " Automated Migration Test"
echo "======================================"

FAILED=0

echo ""
echo "Checking migration_db..."

DATABASE_EXISTS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW DATABASES LIKE '\''migration_db'\'';"' 2>/dev/null)

if [ "$DATABASE_EXISTS" = "migration_db" ]; then
    echo "PASS: migration_db exists"
else
    echo "FAIL: migration_db does not exist"
    FAILED=1
fi

echo ""
echo "Checking required tables..."

TABLES=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "USE migration_db; SHOW TABLES;"' 2>/dev/null)

for TABLE in users products orders order_items
do
    echo "$TABLE" | grep -q "$TABLE"

    if [ $? -eq 0 ]; then
        echo "PASS: $TABLE table exists"
    else
        echo "FAIL: $TABLE table does not exist"
        FAILED=1
    fi
done

echo ""
echo "Checking row counts..."

USERS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SELECT COUNT(*) FROM migration_db.users;"' 2>/dev/null)
PRODUCTS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SELECT COUNT(*) FROM migration_db.products;"' 2>/dev/null)
ORDERS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SELECT COUNT(*) FROM migration_db.orders;"' 2>/dev/null)
ORDER_ITEMS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SELECT COUNT(*) FROM migration_db.order_items;"' 2>/dev/null)

if [ "$USERS" = "5" ]; then
    echo "PASS: users row count = 5"
else
    echo "FAIL: users row count is $USERS"
    FAILED=1
fi

if [ "$PRODUCTS" = "5" ]; then
    echo "PASS: products row count = 5"
else
    echo "FAIL: products row count is $PRODUCTS"
    FAILED=1
fi

if [ "$ORDERS" = "4" ]; then
    echo "PASS: orders row count = 4"
else
    echo "FAIL: orders row count is $ORDERS"
    FAILED=1
fi

if [ "$ORDER_ITEMS" = "5" ]; then
    echo "PASS: order_items row count = 5"
else
    echo "FAIL: order_items row count is $ORDER_ITEMS"
    FAILED=1
fi

echo ""
echo "======================================"

if [ "$FAILED" -eq 0 ]; then
    echo "AUTOMATED MIGRATION TEST PASSED"
    exit 0
else
    echo "AUTOMATED MIGRATION TEST FAILED"
    exit 1
fi