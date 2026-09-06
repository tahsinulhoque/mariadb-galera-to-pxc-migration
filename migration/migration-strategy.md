# Migration Strategy

## Objective

Select the most suitable approach for migrating the MariaDB Galera
Cluster to the Percona XtraDB Cluster (PXC).

## Migration Approaches Considered

### 1. Dump and Restore

The MariaDB database is exported using `mysqldump` and the resulting
backup is restored into the PXC cluster.

**Pros:**
- Simple implementation
- Easy to test and validate
- No replication configuration required
- Suitable for the current test environment

**Cons:**
- Requires downtime during migration
- Not ideal for very large databases

### 2. Async Replication Bridge

The MariaDB source cluster is used as the source for asynchronous
replication, allowing the PXC cluster to receive changes before
cutover.

**Pros:**
- Can reduce final migration downtime
- Target can be synchronized before cutover

**Cons:**
- More complex configuration
- Requires additional replication testing
- Higher operational complexity

## Comparison

| Criteria | Dump and Restore | Async Replication Bridge |
|---|---|---|
| Implementation complexity | Low | High |
| Downtime | Higher | Lower |
| Setup effort | Low | High |
| Replication required | No | Yes |
| Testing effort | Low | High |
| Suitable for current test environment | Yes | Requires additional testing |

## Selected Approach

**Dump and Restore**

Dump and Restore is selected as the migration approach for this
project.

The approach has already been tested during the PXC test-cluster
setup. The `migration_db` database was successfully backed up from
the MariaDB source and restored into the PXC cluster.

## Decision

The migration will proceed with the Dump and Restore approach.

The actual migration testing, cutover, validation, and rollback activities will be handled in the subsequent migration tasks.
