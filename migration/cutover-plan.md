# Cutover Plan

## Objective

Define the steps required to switch the application database connection
from the MariaDB Galera Cluster to the Percona XtraDB Cluster (PXC).

The cutover will be performed after successful test migration and validation.

---

## Current Database

Source database:

- MariaDB Galera Cluster
- Database: `migration_db`

Source nodes:

- mariadb-node1
- mariadb-node2
- mariadb-node3

---

## Target Database

Target database:

- Percona XtraDB Cluster (PXC)
- Database: `migration_db`

PXC nodes:

- pxc-node1
- pxc-node2
- pxc-node3

---

## Pre-Cutover Checks

Before starting the cutover, verify:

- PXC cluster is running.
- All PXC nodes are in `Synced` state.
- PXC cluster status is `Primary`.
- PXC cluster size is 3.
- `migration_db` exists on PXC.
- Required tables exist.
- Data validation has passed.
- A recent source database backup is available.

---

## Cutover Steps

### Step 1: Stop Application Writes

Stop application traffic or put the application into maintenance mode
to prevent new database writes during the cutover.

### Step 2: Verify Source Database

Verify that the MariaDB Galera source database is accessible and healthy.

### Step 3: Take Final Database Backup

Create a final backup of `migration_db` before the database switch.

```bash
mysqldump --single-transaction --skip-lock-tables --skip-add-locks \
--databases migration_db > migration_db_final.sql
```
### Step 4: Restore Final Data

Restore the final backup into the PXC target cluster if any changes
were made on the source database after the previous test migration.

### Step 5: Validate Target Database

Verify:

- Database exists.
- Tables exist.
- Row counts match the source.
- Foreign key relationships are present.

### Step 6: Switch Database Connection

Update the application database connection configuration so that it
points to the PXC cluster instead of the MariaDB Galera cluster.

### Step 7: Start Application Traffic

Remove maintenance mode and allow application traffic to resume.

### Step 8: Post-Cutover Verification

Verify:

- Application can connect to the database.
- Application read operations work.
- Application write operations work.
- No database errors are reported.
- PXC nodes remain `Synced`.

---

## Post-Cutover Monitoring

After the cutover, monitor:

- PXC node health.
- Cluster size.
- Cluster status.
- Node synchronization state.
- Application database errors.
- Application response status.

---

## Cutover Success Criteria

The cutover is considered successful when:

- Application connects successfully to PXC.
- Database operations work normally.
- Data validation passes.
- PXC cluster remains `Primary`.
- All three PXC nodes remain `Synced`.
- No critical database errors are observed.

---

## Rollback Trigger

Rollback should be considered if:

- Application cannot connect to PXC.
- Critical database errors occur.
- Data validation fails.
- PXC cluster becomes unhealthy.
- Application functionality is significantly affected.

The rollback procedure will be documented separately in the rollback plan.