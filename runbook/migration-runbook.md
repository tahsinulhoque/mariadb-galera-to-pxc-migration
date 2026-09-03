# MariaDB Galera to PXC Migration Runbook

## Objective

This runbook documents the database migration process from the
MariaDB Galera Cluster to the Percona XtraDB Cluster (PXC).

---

## Source Database

- Database: `migration_db`
- Cluster: MariaDB Galera
- Nodes:
  - mariadb-node1
  - mariadb-node2
  - mariadb-node3

---

## Target Database

- Database: `migration_db`
- Cluster: Percona XtraDB Cluster (PXC)
- Nodes:
  - pxc-node1
  - pxc-node2
  - pxc-node3

---

## Migration Method

The selected migration method is:

**Dump and Restore**

The database is exported from the MariaDB Galera source cluster
and restored into the PXC target cluster.

---

## Pre-Migration Checks

Before migration:

1. Verify the MariaDB Galera cluster is healthy.
2. Verify the source database `migration_db` exists.
3. Create a database backup.
4. Verify PXC nodes are running.
5. Verify the PXC cluster is in `Primary` state.
6. Verify all PXC nodes are `Synced`.

---

## Database Backup

Create a backup of the source database:

```bash
mysqldump --single-transaction --skip-lock-tables --skip-add-locks \
--databases migration_db > migration_db.sql

```

# PXC Migration Runbook

## Restore to PXC

Restore the database backup into the PXC cluster:

```bash
mysql -uroot -p < migration_db.sql
```

> The restore should be performed on the PXC cluster.

---

## Test Migration

After restoring the database:

1. Verify `migration_db` exists.
2. Verify all required tables exist.
3. Compare row counts.
4. Verify table structures and foreign keys.
5. Verify data can be read successfully.
6. Verify PXC cluster health.

---

## Cutover

During cutover:

1. Stop application writes.
2. Verify the source database is healthy.
3. Take a final database backup.
4. Restore final changes to PXC if required.
5. Validate the target database.
6. Change the application database connection to PXC.
7. Start application traffic.
8. Verify application database operations.

---

## Post-Cutover Validation

Verify:

- PXC cluster size is 3.
- Cluster status is `Primary`.
- All nodes are `Synced`.
- WSREP is ready.
- `migration_db` exists.
- Required tables exist.
- Row counts match the source.
- Data can be read successfully.

---

## Rollback

Rollback should be performed if:

- Application cannot connect to PXC.
- Critical database errors occur.
- Data validation fails.
- PXC cluster becomes unhealthy.
- Application functionality is significantly affected.

### Rollback Procedure

1. Stop application traffic.
2. Verify MariaDB Galera cluster health.
3. Restore the application database connection to MariaDB Galera.
4. Verify `migration_db` is available.
5. Verify application read/write operations.
6. Verify MariaDB Galera cluster status.

---

## Migration Success Criteria

The migration is considered successful when:

- PXC cluster is healthy.
- All PXC nodes are `Synced`.
- `migration_db` is available.
- Required tables are present.
- Data validation passes.
- Application database operations work normally.

---

## Important Notes

- Always keep a recent database backup before cutover.
- Do not start application traffic until target validation is complete.
- Rollback should be used if critical migration issues are detected.