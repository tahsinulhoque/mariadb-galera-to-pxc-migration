#!/bin/bash

echo "======================================"
echo " PXC Cluster Monitoring Check"
echo "======================================"

FAILED=0

echo ""
echo "Checking PXC nodes..."

for NODE in pxc-node1 pxc-node2 pxc-node3
do
    STATUS=$(docker inspect --format='{{.State.Status}}' "$NODE" 2>/dev/null)

    if [ "$STATUS" = "running" ]; then
        echo "PASS: $NODE is running"
    else
        echo "FAIL: $NODE is not running"
        FAILED=1
    fi
done

echo ""
echo "Checking cluster status..."

if docker inspect --format='{{.State.Status}}' pxc-node1 2>/dev/null | grep -q "running"; then

    CLUSTER_SIZE=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_cluster_size'\'';"' 2>/dev/null | awk '{print $2}')

    if [ "$CLUSTER_SIZE" = "3" ]; then
        echo "PASS: Cluster size = 3"
    else
        echo "FAIL: Cluster size = $CLUSTER_SIZE"
        FAILED=1
    fi

    CLUSTER_STATUS=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_cluster_status'\'';"' 2>/dev/null | awk '{print $2}')

    if [ "$CLUSTER_STATUS" = "Primary" ]; then
        echo "PASS: Cluster status = Primary"
    else
        echo "FAIL: Cluster status = $CLUSTER_STATUS"
        FAILED=1
    fi

    NODE_STATE=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_local_state_comment'\'';"' 2>/dev/null | awk '{print $2}')

    if [ "$NODE_STATE" = "Synced" ]; then
        echo "PASS: Node state = Synced"
    else
        echo "FAIL: Node state = $NODE_STATE"
        FAILED=1
    fi

    WSREP_READY=$(docker exec pxc-node1 sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "SHOW STATUS LIKE '\''wsrep_ready'\'';"' 2>/dev/null | awk '{print $2}')

    if [ "$WSREP_READY" = "ON" ]; then
        echo "PASS: WSREP ready = ON"
    else
        echo "FAIL: WSREP ready = $WSREP_READY"
        FAILED=1
    fi

else
    echo "SKIP: Cluster checks because pxc-node1 is not running"
fi

echo ""
echo "======================================"

if [ "$FAILED" -eq 0 ]; then
    echo "CLUSTER MONITORING: HEALTHY"
    exit 0
else
    echo "CLUSTER MONITORING: UNHEALTHY"
    exit 1
fi