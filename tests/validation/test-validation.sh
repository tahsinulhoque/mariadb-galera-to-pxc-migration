#!/bin/bash

echo "======================================"
echo " Automated Validation Test"
echo "======================================"

FAILED=0

echo ""
echo "Checking PXC cluster..."

CLUSTER_SIZE=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_cluster_size'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$CLUSTER_SIZE" = "3" ]; then
    echo "PASS: Cluster size is 3"
else
    echo "FAIL: Cluster size is $CLUSTER_SIZE"
    FAILED=1
fi

CLUSTER_STATUS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_cluster_status'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$CLUSTER_STATUS" = "Primary" ]; then
    echo "PASS: Cluster status is Primary"
else
    echo "FAIL: Cluster status is $CLUSTER_STATUS"
    FAILED=1
fi

NODE_STATE=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_local_state_comment'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$NODE_STATE" = "Synced" ]; then
    echo "PASS: Node state is Synced"
else
    echo "FAIL: Node state is $NODE_STATE"
    FAILED=1
fi

WSREP_READY=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_ready'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$WSREP_READY" = "ON" ]; then
    echo "PASS: WSREP is ready"
else
    echo "FAIL: WSREP is $WSREP_READY"
    FAILED=1
fi

echo ""
echo "Checking database..."

DATABASE_EXISTS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW DATABASES LIKE '\''migration_db'\'';"' 2>/dev/null)

if [ "$DATABASE_EXISTS" = "migration_db" ]; then
    echo "PASS: migration_db exists"
else
    echo "FAIL: migration_db does not exist"
    FAILED=1
fi

echo ""
echo "======================================"

if [ "$FAILED" -eq 0 ]; then
    echo "AUTOMATED VALIDATION TEST PASSED"
    exit 0
else
    echo "AUTOMATED VALIDATION TEST FAILED"
    exit 1
fi