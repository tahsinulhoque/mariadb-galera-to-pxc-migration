# Disaster Recovery Verification

## Objective

Verify that the PXC cluster can continue operating when one node fails and that the failed node can successfully rejoin the cluster after restart.

## Test Environment

- Database Cluster: Percona XtraDB Cluster (PXC)
- Nodes: pxc-node1, pxc-node2, pxc-node3
- Test Database: migration_db
- Migration Project: MariaDB Galera to PXC

## Initial Cluster State

Before starting the failure test, the cluster was verified as healthy:

- Cluster size: 3
- Cluster status: Primary
- Node state: Synced
- WSREP ready: ON

## Failure Test

### Step 1: Stop One Node

Node 3 was intentionally stopped:

```bash
docker stop pxc-node3
```

The remaining nodes continued running.

### Step 2: Verify Cluster After Node Failure

The cluster status was checked from pxc-node1.

Results:

```text
wsrep_cluster_size = 2
wsrep_cluster_status = Primary
wsrep_local_state_comment = Synced
wsrep_ready = ON
```

### Result

The remaining two-node cluster remained operational after the failure of pxc-node3.

**Status: PASS**

## Recovery Test

### Step 3: Restart Failed Node

The failed node was restarted:

```bash
docker start pxc-node3
```

### Step 4: Verify Node Rejoin

The pxc-node3 logs were checked after restart.

The node successfully:

- Joined the cluster
- Completed state transfer
- Changed from JOINED to SYNCED
- Became ready for connections

Relevant verification:

```text
Shifting JOINED -> SYNCED
Server synced with group
Server status change joined -> synced
Synchronized with group, ready for connections
```

### Result

The failed node successfully rejoined the PXC cluster and reached the Synced state.

**Status: PASS**

## Final Cluster Verification

The existing cluster monitoring check was executed:

```bash
bash validation/check-cluster.sh
```

Final results:

```text
PASS: pxc-node1 is running
PASS: pxc-node2 is running
PASS: pxc-node3 is running
PASS: Cluster size = 3
PASS: Cluster status = Primary
PASS: Node state = Synced
PASS: WSREP ready = ON

CLUSTER MONITORING: HEALTHY
```

## Overall Result

**DISASTER RECOVERY VERIFICATION: PASS**

The test confirmed that:

1. The PXC cluster remained operational after one node failure.
2. The failed node successfully restarted.
3. The failed node rejoined the cluster.
4. The recovered node reached the Synced state.
5. The final three-node cluster returned to a healthy Primary state.