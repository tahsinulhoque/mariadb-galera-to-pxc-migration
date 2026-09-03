# MariaDB Galera to Percona XtraDB Cluster (PXC) Migration

A Docker-based proof-of-concept project demonstrating the migration of a MariaDB Galera Cluster to a Percona XtraDB Cluster (PXC) using the **Dump and Restore** migration approach.

The project covers compatibility checking, PXC cluster setup, database backup and restore, test migration, cutover planning, validation, rollback planning, and operational documentation.

---

## Project Overview

This project simulates a database migration from:

**Source**

* MariaDB Galera Cluster
* 3-node cluster
* Database: `migration_db`

**Target**

* Percona XtraDB Cluster (PXC)
* 3-node cluster
* Database: `migration_db`

The migration is performed using a logical database dump followed by restoration into the PXC cluster.

---

## Architecture

```text
                    Source Environment
              MariaDB Galera Cluster
              ┌──────────────────────┐
              │                      │
              │  mariadb-node1       │
              │  mariadb-node2       │
              │  mariadb-node3       │
              │                      │
              └──────────┬───────────┘
                         │
                    mysqldump
                         │
                         ▼
                  migration_db.sql
                         │
                       Restore
                         │
                         ▼
              Target Environment
              Percona XtraDB Cluster
              ┌──────────────────────┐
              │                      │
              │  pxc-node1           │
              │  pxc-node2           │
              │  pxc-node3           │
              │                      │
              └──────────────────────┘
```

---

## Technology Stack

| Component        | Technology                 |
| ---------------- | -------------------------- |
| Source Database  | MariaDB 10.11              |
| Source Cluster   | MariaDB Galera             |
| Target Database  | Percona XtraDB Cluster 8.4 |
| Containerization | Docker / Docker Compose    |
| Migration Method | Dump and Restore           |
| Database         | MySQL-compatible SQL       |
| Configuration    | MySQL configuration files  |
| Validation       | SQL and Shell scripts      |
| Documentation    | Markdown                   |

---

## Project Structure

```text
mariadb-galera-to-pxc-migration/
│
├── README.md
├── .gitignore
│
├── compatibility/
│   └── compatibility-check.md
│
├── config/
│
├── database/
│   ├── backup/
│   ├── schema/
│   │   └── schema.sql
│   └── seed/
│       └── sample-data.sql
│
├── docker/
│   ├── mariadb-galera/
│   │   └── docker-compose.yml
│   │
│   └── pxc/
│       ├── docker-compose.yml
│       ├── Dockerfile
│       ├── .env
│       ├── certs/
│       └── conf.d/
│           └── custom.cnf
│
├── migration/
│   ├── migration-strategy.md
│   ├── test-migration.md
│   ├── cutover-plan.md
│   │
│   ├── dump-restore/
│   │   └── README.md
│   │
│   ├── replication-bridge/
│   │   └── README.md
│   │
│   ├── export-database.sh
│   ├── import-database.sh
│   └── transfer-database.sh
│
├── rollback/
│   └── rollback.sh
│
├── runbook/
│   └── migration-runbook.md
│
├── validation/
│   ├── check-cluster.sh
│   ├── checksum-validation.sh
│   ├── compare-row-counts.sh
│   └── validation-report.md
│
└── scripts/
    └── setup/
```

---

## Migration Workflow

The project follows these major stages:

```text
1. Build MariaDB Galera Source Cluster
                ↓
2. Create Sample Database and Data
                ↓
3. Check Compatibility
                ↓
4. Build PXC Target Cluster
                ↓
5. Backup Source Database
                ↓
6. Restore Database to PXC
                ↓
7. Test Migration
                ↓
8. Prepare Cutover
                ↓
9. Validate Target Cluster
                ↓
10. Prepare Rollback
                ↓
11. Create Migration Runbook
```

---

# 1. Source MariaDB Galera Cluster

The source environment consists of three MariaDB Galera nodes:

```text
mariadb-node1
mariadb-node2
mariadb-node3
```

The cluster is configured as a 3-node Galera cluster and is used as the source database environment for the migration.

---

# 2. Source Database

A sample database named `migration_db` is used for the migration.

The database contains the following tables:

```text
migration_db
├── users
├── products
├── orders
└── order_items
```

The database schema is available at:

```text
database/schema/schema.sql
```

Sample data is available at:

```text
database/seed/sample-data.sql
```

---

# 3. Compatibility Check

Before migration, the source database was checked for compatibility with the target PXC environment.

The compatibility check covers:

* Storage engines
* Database schema
* Data types
* Primary keys
* Foreign keys
* Indexes
* Triggers
* Stored routines
* Proxy configuration

The result of the compatibility assessment is documented in:

```text
compatibility/compatibility-check.md
```

---

# 4. PXC Target Cluster

The target environment consists of three PXC nodes:

```text
pxc-node1
pxc-node2
pxc-node3
```

The PXC cluster uses Percona XtraDB Cluster 8.4.

The Docker configuration is located at:

```text
docker/pxc/
```

The PXC configuration includes:

* 3-node cluster
* Cluster bootstrap
* Node joining
* SST configuration
* Encrypted cluster traffic
* TLS certificates

Sensitive files such as `.env`, certificates, and database data directories are excluded from Git using `.gitignore`.

---

# 5. Migration Strategy

Two migration approaches were considered:

### Dump and Restore

A logical backup is created from the MariaDB Galera source and restored into the PXC cluster.

### Async Replication Bridge

An asynchronous replication bridge can be used to keep the target database synchronized with the source during migration.

For this project, **Dump and Restore was selected** because:

* The project database is small.
* The setup is simpler.
* It has fewer moving parts.
* It does not require an additional replication bridge.
* The approach was successfully tested in the PXC environment.

The detailed decision is documented in:

```text
migration/migration-strategy.md
```

---

# 6. Database Backup

The source database can be exported using `mysqldump`.

Example:

```bash
mysqldump --single-transaction --skip-lock-tables --skip-add-locks \
--databases migration_db > migration_db.sql
```

The project uses these options to create a dump suitable for restoring into the PXC environment.

---

# 7. Restore to PXC

The database dump is restored into the PXC cluster.

Example:

```bash
mysql -uroot -p < migration_db.sql
```

The restored database is then checked for:

* Database existence
* Table existence
* Data availability
* Row counts
* Foreign key relationships

---

# 8. Test Migration

A complete test migration was performed using the Dump and Restore approach.

The test included:

1. Creating a source database backup.
2. Restoring the backup into PXC.
3. Checking the migrated database.
4. Checking required tables.
5. Comparing row counts.
6. Checking table structures and foreign keys.
7. Verifying data access.
8. Verifying PXC cluster health.

The test migration result was successful.

Documentation:

```text
migration/test-migration.md
```

---

# 9. Cutover Plan

The cutover plan defines how the application database connection would be switched from MariaDB Galera to PXC.

The planned process includes:

1. Stop application writes.
2. Verify the source database.
3. Create a final backup.
4. Restore final changes to PXC if required.
5. Validate the target database.
6. Change the application database connection to PXC.
7. Start application traffic.
8. Perform post-cutover verification.

Documentation:

```text
migration/cutover-plan.md
```

---

# 10. Validation

After migration, the PXC cluster and migrated database were validated.

The validation checks include:

* PXC cluster size
* Cluster status
* Node synchronization
* WSREP readiness
* Database existence
* Table existence
* Row counts
* Data accessibility
* Foreign key relationships

Expected PXC cluster state:

```text
Cluster Size: 3
Cluster Status: Primary
Node State: Synced
WSREP Ready: ON
```

Expected migrated data:

| Table       | Rows |
| ----------- | ---: |
| users       |    5 |
| products    |    5 |
| orders      |    4 |
| order_items |    5 |

Validation scripts are located in:

```text
validation/
```

Validation results are documented in:

```text
validation/validation-report.md
```

---

# 11. Rollback

A rollback procedure is provided in case the migration causes critical issues.

Rollback may be required if:

* The application cannot connect to PXC.
* Critical database errors occur.
* Data validation fails.
* The PXC cluster becomes unhealthy.
* Application functionality is significantly affected.

The rollback procedure switches the application database connection back to the MariaDB Galera environment.

Rollback script:

```text
rollback/rollback.sh
```

---

# 12. Runbook

The complete migration procedure is documented in:

```text
runbook/migration-runbook.md
```

The runbook covers:

* Pre-migration checks
* Database backup
* PXC restore
* Test migration
* Cutover
* Post-cutover validation
* Rollback
* Migration success criteria

---

# Jira Task Mapping

| Jira Task | Description                | Status    |
| --------- | -------------------------- | --------- |
| DEV-810   | Compatibility Check        | Completed |
| DEV-811   | PXC Setup and Data Restore | Completed |
| DEV-812   | Migration Strategy         | Completed |
| DEV-813   | Test Migration             | Completed |
| DEV-814   | Cutover Plan               | Completed |
| DEV-815   | Validation                 | Completed |
| DEV-816   | Rollback                   | Completed |
| DEV-817   | Migration Runbook          | Completed |

---

# Validation Result

The migration test successfully demonstrated that:

* The PXC cluster contains 3 nodes.
* The cluster is in `Primary` state.
* PXC nodes are `Synced`.
* WSREP is ready.
* `migration_db` exists.
* Required tables are present.
* Expected row counts are available.
* Migrated data can be read successfully.

**Overall migration test result: PASS**

---

# Security Notes

The repository does not intentionally store sensitive runtime data.

The following files/directories should remain excluded from Git:

```text
.env
certs/
data-*/
```

Database passwords, private keys, certificates, and runtime database files should not be committed to the repository.

---

# Limitations

This project is a **Docker-based migration proof of concept / test environment**.

It demonstrates the migration workflow using a sample database. It does not represent a live production migration.

Actual production migration should additionally consider:

* Application-specific dependencies
* Production database size
* Maintenance window
* Backup retention
* Monitoring
* Application traffic management
* Production rollback requirements

---

# Project Outcome

This project demonstrates an end-to-end database migration workflow from a **MariaDB Galera Cluster to a Percona XtraDB Cluster (PXC)** using the **Dump and Restore** approach.

The migration process was tested, validated, documented, and supported with a rollback procedure and operational runbook.
