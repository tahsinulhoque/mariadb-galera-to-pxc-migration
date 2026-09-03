#!/bin/bash

echo "======================================"
echo " Production Safety Gate"
echo "======================================"

FAILED=0

echo ""
echo "Checking PXC Node 1..."

docker inspect --format='{{.State.Status}}' pxc-node1 | grep -q "running"

if [ $? -eq 0 ]; then
    echo "PASS: pxc-node1 is running"
else
    echo "FAIL: pxc-node1 is not running"
    FAILED=1
fi

echo ""
echo "Checking PXC Node 2..."

docker inspect --format='{{.State.Status}}' pxc-node2 | grep -q "running"

if [ $? -eq 0 ]; then
    echo "PASS: pxc-node2 is running"
else
    echo "FAIL: pxc-node2 is not running"
    FAILED=1
fi

echo ""
echo "Checking PXC Node 3..."

docker inspect --format='{{.State.Status}}' pxc-node3 | grep -q "running"

if [ $? -eq 0 ]; then
    echo "PASS: pxc-node3 is running"
else
    echo "FAIL: pxc-node3 is not running"
    FAILED=1
fi

echo ""
echo "Checking PXC Cluster..."

CLUSTER_SIZE=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_cluster_size'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$CLUSTER_SIZE" = "3" ]; then
    echo "PASS: Cluster size is 3"
else
    echo "FAIL: Cluster size is not 3"
    FAILED=1
fi

CLUSTER_STATUS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_cluster_status'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$CLUSTER_STATUS" = "Primary" ]; then
    echo "PASS: Cluster status is Primary"
else
    echo "FAIL: Cluster status is not Primary"
    FAILED=1
fi

NODE_STATE=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_local_state_comment'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$NODE_STATE" = "Synced" ]; then
    echo "PASS: Node state is Synced"
else
    echo "FAIL: Node state is not Synced"
    FAILED=1
fi

WSREP_READY=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_ready'\'';"' 2>/dev/null | awk '{print $2}')

if [ "$WSREP_READY" = "ON" ]; then
    echo "PASS: WSREP is ready"
else
    echo "FAIL: WSREP is not ready"
    FAILED=1
fi

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
echo "======================================"

if [ "$FAILED" -eq 0 ]; then
    echo "SAFETY GATE PASSED"
    echo "Migration can proceed."
    exit 0
else
    echo "SAFETY GATE FAILED"
    echo "Migration must not continue."
    exit 1
fi