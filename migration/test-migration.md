## Test Migration Result

### Source Database

The source MariaDB Galera cluster was used as the migration source.

Database:
- `migration_db`

### Migration Method

The test migration was performed using the Dump and Restore approach.

A SQL dump was created from the source MariaDB database and restored into the PXC test cluster.

### PXC Cluster Verification

The PXC test cluster was verified with:

- Node 1: Synced
- Node 2: Synced
- Node 3: Synced
- Cluster status: Primary
- Cluster size: 3

### Data Verification

The restored data was verified on the PXC cluster.

| Table | Expected Rows | Restored Rows | Result |
|---|---:|---:|---|
| users | 5 | 5 | PASS |
| products | 5 | 5 | PASS |
| orders | 4 | 4 | PASS |
| order_items | 5 | 5 | PASS |

### Result

The test migration completed successfully.

The `migration_db` database was successfully restored into the PXC test cluster, and the row counts matched the source database.
