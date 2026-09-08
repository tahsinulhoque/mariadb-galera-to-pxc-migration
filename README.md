# MariaDB Galera to Percona XtraDB Cluster (PXC) Migration

A Docker-based proof-of-concept project demonstrating an end-to-end migration workflow from a **MariaDB Galera Cluster** to a **Percona XtraDB Cluster (PXC)** using the **Dump and Restore** approach.

The project covers database compatibility assessment, source and target cluster setup, backup and restore, migration testing, production safety gates, automated testing, CI validation, cluster monitoring, disaster recovery verification, migration state tracking, cutover planning, validation, rollback, and operational runbook documentation.

---

## Project Overview

This project simulates a database migration from:

### Source

- MariaDB 10.11
- MariaDB Galera Cluster
- 3-node cluster
- Database: `migration_db`

### Target

- Percona XtraDB Cluster 8.4
- 3-node cluster
- Database: `migration_db`

### Migration Method

**Dump and Restore**

The source database is exported using `mysqldump` and restored into the PXC cluster.

---

## Architecture

```text
                  SOURCE ENVIRONMENT
              MariaDB Galera Cluster
                       │
        ┌──────────────┼──────────────┐
        │              │              │
  mariadb-node1  mariadb-node2  mariadb-node3
        │
        │
        │ mysqldump
        ▼
  migration_db.sql
        │
        │ Restore
        ▼
                 TARGET ENVIRONMENT
              Percona XtraDB Cluster
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    pxc-node1      pxc-node2      pxc-node3
```

---

## Technology Stack

| Component | Technology |
|---|---|
| Source Database | MariaDB 10.11 |
| Source Cluster | MariaDB Galera |
| Target Database | Percona XtraDB Cluster 8.4 |
| Containerization | Docker / Docker Compose |
| Migration Method | Dump and Restore |
| Database Tooling | `mysqldump`, `mysql` |
| Cluster Technology | Galera / WSREP |
| Automation | Bash |
| CI | GitHub Actions |
| Validation | SQL + Bash scripts |
| Documentation | Markdown |
| Development Environment | Docker Desktop / VS Code |

---

## Project Structure

```text
mariadb-galera-to-pxc-migration/
│
├── .github/
│   └── workflows/
│       └── migration-ci.yml
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
│   ├── dump-restore/
│   │   └── README.md
│   │
│   ├── replication-bridge/
│   │   └── README.md
│   │
│   ├── cutover-plan.md
│   ├── export-database.sh
│   ├── import-database.sh
│   ├── migration-state.md
│   ├── migration-strategy.md
│   ├── production-safety-check.sh
│   ├── production-safety-gates.md
│   ├── rollback-plan.md
│   ├── test-migration.md
│   └── transfer-database.sh
│
├── rollback/
│   └── rollback.sh
│
├── runbook/
│   └── migration-runbook.md
│
├── scripts/
│   └── setup/
│
├── tests/
│   ├── migration/
│   │   └── test-migration.sh
│   ├── validation/
│   │   └── test-validation.sh
│   ├── automated-testing.md
│   └── disaster-recovery-verification.md
│
├── validation/
│   ├── check-cluster.sh
│   ├── checksum-validation.sh
│   ├── compare-row-counts.sh
│   └── validation-report.md
│
├── .gitignore
└── README.md
```

---

# Migration Workflow

The project follows a controlled migration workflow:

```text
1. Build MariaDB Galera Source Cluster
                 ↓
2. Create Source Database and Sample Data
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
8. Production Safety Gates
                 ↓
9. Automated Testing
                 ↓
10. CI Validation
                 ↓
11. Monitoring / Observability Checks
                 ↓
12. Cutover Planning
                 ↓
13. Validation
                 ↓
14. Disaster Recovery Verification
                 ↓
15. Rollback Readiness
                 ↓
16. Migration State Tracking
                 ↓
17. Production Migration
```

---

# 1. Source MariaDB Galera Cluster

The source environment consists of three MariaDB Galera nodes:

```text
mariadb-node1
mariadb-node2
mariadb-node3
```

The cluster is configured as a 3-node Galera cluster and is used as the source database environment.

Source cluster configuration:

- MariaDB 10.11
- 3 Galera nodes
- Docker-based deployment
- Galera replication
- Primary cluster state
- Synchronized nodes

The source cluster configuration is available under:

```text
docker/mariadb-galera/
```

---

# 2. Source Database

A sample database named `migration_db` is used for the migration.

Database structure:

```text
migration_db
├── users
├── products
├── orders
└── order_items
```

The schema is available at:

```text
database/schema/schema.sql
```

Sample data is available at:

```text
database/seed/sample-data.sql
```

Expected sample data:

| Table | Rows |
|---|---:|
| users | 5 |
| products | 5 |
| orders | 4 |
| order_items | 5 |

---

# 3. Compatibility Check

Before migration, the source database was assessed for compatibility with the PXC target environment.

The compatibility assessment covers:

- Storage engines
- Database schema
- Data types
- Primary keys
- Foreign keys
- Indexes
- Triggers
- Stored routines
- Proxy configuration

The result is documented in:

```text
compatibility/compatibility-check.md
```

The compatibility check confirmed that the sample database uses standard InnoDB tables with supported schema features and relationships.

---

# 4. PXC Target Cluster

The target environment consists of three PXC nodes:

```text
pxc-node1
pxc-node2
pxc-node3
```

Target cluster:

- Percona XtraDB Cluster 8.4
- 3 nodes
- Docker Compose
- Cluster bootstrap
- Node joining
- SST configuration
- Encrypted cluster traffic
- TLS certificates

PXC configuration:

```text
docker/pxc/
```

Sensitive runtime files are excluded from Git.

These include:

```text
.env
certs/
data-*/
```

---

# 5. Migration Strategy

Two migration approaches were considered:

### Dump and Restore

Create a logical backup from the MariaDB Galera source and restore it into PXC.

### Async Replication Bridge

Use an asynchronous replication bridge to keep the target database synchronized with the source during migration.

## Selected Approach

**Dump and Restore**

The Dump and Restore approach was selected because:

- The test database is small.
- The setup is simpler.
- It has fewer moving parts.
- It does not require an additional replication bridge.
- The approach was successfully tested in the PXC environment.

Detailed strategy:

```text
migration/migration-strategy.md
```

---

# 6. Database Backup

The source database is exported using `mysqldump`.

Example:

```bash
mysqldump \
  --single-transaction \
  --skip-lock-tables \
  --skip-add-locks \
  --databases migration_db \
  > migration_db.sql
```

The additional dump options are used to make the logical backup suitable for restoration into the PXC environment.

Backup files are stored under:

```text
database/backup/
```

---

# 7. Restore to PXC

The database dump is restored into the PXC cluster.

Example:

```bash
mysql -uroot -p < migration_db.sql
```

After restoration, the following are verified:

- Database existence
- Table existence
- Data availability
- Row counts
- Table structure
- Foreign key relationships

---

# 8. Test Migration

A complete test migration was performed using the selected Dump and Restore approach.

The test included:

1. Creating a source database backup.
2. Restoring the backup into PXC.
3. Checking the migrated database.
4. Checking required tables.
5. Comparing row counts.
6. Checking table structures.
7. Checking foreign key relationships.
8. Verifying data access.
9. Verifying PXC cluster health.

Test migration documentation:

```text
migration/test-migration.md
```

Test result:

```text
PASS
```

---

# 9. Production Safety Gates

Production safety gates were added to prevent migration from proceeding when the target PXC environment is not healthy.

The safety gate checks:

- PXC node 1 is running
- PXC node 2 is running
- PXC node 3 is running
- Cluster size is 3
- Cluster status is `Primary`
- Node state is `Synced`
- WSREP is ready
- `migration_db` exists

Safety gate documentation:

```text
migration/production-safety-gates.md
```

Safety check script:

```text
migration/production-safety-check.sh
```

Expected successful result:

```text
SAFETY GATE PASSED
Migration can proceed.
```

If a critical check fails, the migration must not continue.

---

# 10. Automated Testing

Automated migration and validation tests were added to verify the target environment.

Migration test:

```text
tests/migration/test-migration.sh
```

Validation test:

```text
tests/validation/test-validation.sh
```

The automated tests verify:

- Database existence
- Required tables
- Expected row counts
- PXC cluster size
- Cluster status
- Node synchronization
- WSREP readiness

Expected migration data:

```text
users       = 5
products    = 5
orders      = 4
order_items = 5
```

Documentation:

```text
tests/automated-testing.md
```

---

# 11. CI Validation

GitHub Actions is used to automatically validate the migration project on repository changes.

Workflow:

```text
.github/workflows/migration-ci.yml
```

The CI workflow runs on:

- Push to `main`
- Push to `master`
- Pull requests

The CI pipeline performs:

### Bash Syntax Validation

All `.sh` scripts are checked using:

```bash
bash -n
```

### Docker Compose Validation

The MariaDB Galera Docker Compose configuration is validated.

### Required File Validation

The workflow checks that important migration documentation and configuration files are present.

CI workflow:

```text
Git Push / Pull Request
        ↓
GitHub Actions
        ↓
Bash Syntax Check
        ↓
Docker Compose Validation
        ↓
Required File Check
        ↓
CI Validation Result
```

The CI workflow is a validation pipeline for the migration project. It does not perform an actual production deployment.

---

# 12. Monitoring / Observability

Cluster health monitoring checks were added to verify the operational state of the PXC cluster.

Monitoring script:

```text
validation/check-cluster.sh
```

The monitoring check verifies:

- PXC node availability
- Cluster size
- Cluster status
- Local node state
- WSREP readiness

Expected healthy state:

```text
Cluster size = 3
Cluster status = Primary
Node state = Synced
WSREP ready = ON
```

Example healthy result:

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

---

# 13. Cutover Plan

A controlled cutover plan is documented for switching application database traffic from MariaDB Galera to PXC.

The planned sequence is:

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

The cutover plan is a documented procedure for a future production migration. It does not indicate that a live production cutover has already been performed.

---

# 14. Validation

After the test migration, the PXC cluster and migrated database were validated.

Validation includes:

- Cluster size
- Cluster status
- Node synchronization
- WSREP readiness
- Database existence
- Table existence
- Row counts
- Data accessibility
- Foreign key relationships

Expected cluster state:

```text
Cluster Size: 3
Cluster Status: Primary
Node State: Synced
WSREP Ready: ON
```

Expected data:

| Table | Expected Rows |
|---|---:|
| users | 5 |
| products | 5 |
| orders | 4 |
| order_items | 5 |

Validation scripts:

```text
validation/
```

Validation report:

```text
validation/validation-report.md
```

Overall validation result:

```text
PASS
```

---

# 15. Disaster Recovery Verification

A node failure and recovery scenario was tested on the PXC cluster.

## Failure Scenario

One PXC node was stopped:

```bash
docker stop pxc-node3
```

The remaining cluster was verified.

Result:

```text
Cluster size = 2
Cluster status = Primary
Node state = Synced
WSREP ready = ON
```

The remaining cluster stayed operational.

## Recovery

The failed node was restarted:

```bash
docker start pxc-node3
```

The node successfully:

- Rejoined the cluster
- Completed state transfer
- Changed from `JOINED` to `SYNCED`
- Became ready for connections

Final monitoring result:

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

Documentation:

```text
tests/disaster-recovery-verification.md
```

Result:

```text
DISASTER RECOVERY VERIFICATION: PASS
```

---

# 16. Rollback

A rollback procedure is provided in case critical issues occur during or after migration.

Rollback may be required if:

- The application cannot connect to PXC.
- Critical database errors occur.
- Data validation fails.
- The PXC cluster becomes unhealthy.
- Application functionality is significantly affected.

Rollback approach:

```text
Stop application traffic
        ↓
Verify MariaDB Galera
        ↓
Restore application DB connection
        ↓
Verify database access
        ↓
Verify cluster health
```

Rollback script:

```text
rollback/rollback.sh
```

Additional rollback planning:

```text
migration/rollback-plan.md
```

---

# 17. Migration State Tracking

Migration state tracking documents the current stage of the migration process.

State flow:

```text
NOT_STARTED
     ↓
COMPATIBILITY_CHECKED
     ↓
TEST_MIGRATION_COMPLETED
     ↓
READY_FOR_CUTOVER
     ↓
CUTOVER_COMPLETED
     ↓
VALIDATION_PASSED
     ↓
COMPLETED
```

Failure path:

```text
FAILED
   ↓
ROLLED_BACK
```

Migration state documentation:

```text
migration/migration-state.md
```

Current project state:

```text
VALIDATION_PASSED
```

The final production migration remains pending until an approved production migration and post-cutover validation are performed.

---

# 18. Migration Runbook

The complete operational migration procedure is documented in:

```text
runbook/migration-runbook.md
```

The runbook covers:

- Pre-migration checks
- Source database backup
- PXC restore
- Test migration
- Cutover
- Post-cutover validation
- Rollback
- Migration success criteria

The runbook provides a repeatable procedure for executing the migration workflow.

---

# 19. Jira Task Mapping

| Jira Task | Description | Status |
|---|---|---|
| DEV-810 | Compatibility Check | Completed |
| DEV-811 | PXC Setup and Data Restore | Completed |
| DEV-812 | Migration Strategy | Completed |
| DEV-813 | Test Migration | Completed |
| DEV-814 | Cutover Plan | Completed |
| DEV-815 | Validation | Completed |
| DEV-816 | Rollback | Completed |
| DEV-817 | Migration Runbook | Completed |

---

# 20. Additional Engineering Requirements

The project was extended to address the following operational requirements:

| Requirement | Implementation |
|---|---|
| Production Safety Gates | `migration/production-safety-check.sh` |
| Automated Testing | `tests/migration/`, `tests/validation/` |
| CI/CD Validation | `.github/workflows/migration-ci.yml` |
| Monitoring / Observability | `validation/check-cluster.sh` |
| Disaster Recovery Verification | `tests/disaster-recovery-verification.md` |
| Migration State Tracking | `migration/migration-state.md` |

---

# 21. Security Considerations

Sensitive runtime information must not be committed to the repository.

The following are excluded through `.gitignore`:

```text
.env
certs/
data-*/
```

Do not commit:

- Database passwords
- Private keys
- TLS certificates
- Runtime database files
- Local Docker data directories
- Production credentials

For production usage, credentials should be provided through an appropriate secret-management mechanism.

---

# 22. Validation Summary

The migration test environment successfully demonstrated:

- A 3-node MariaDB Galera source cluster.
- A 3-node PXC target cluster.
- Successful logical database backup.
- Successful database restore into PXC.
- Required tables and data available after migration.
- Expected row counts verified.
- PXC cluster in `Primary` state.
- PXC nodes in `Synced` state.
- WSREP readiness confirmed.
- Production safety gates passed.
- Automated migration and validation tests passed.
- CI validation configured through GitHub Actions.
- Cluster monitoring checks passed.
- Single-node failure and recovery successfully verified.
- Migration state tracking documented.
- Rollback procedure documented.
- Operational migration runbook documented.

Overall test environment result:

```text
MIGRATION TEST: PASS
```

---

# 23. Limitations

This project is a Docker-based proof-of-concept and test environment.

It demonstrates the migration workflow using a sample database and does not represent an actual live production migration.

A real production migration would additionally require environment-specific consideration of:

- Production database size
- Application dependencies
- Application traffic
- Maintenance window
- Backup retention
- Recovery Point Objective (RPO)
- Recovery Time Objective (RTO)
- Production monitoring
- Application connection management
- Production rollback requirements
- Production change approval
- Final production validation

The cutover and final production migration remain operational procedures to be executed only after appropriate approval and production readiness checks.

---

# 24. Project Outcome

This project demonstrates an end-to-end database migration workflow from:

```text
MariaDB Galera Cluster
        ↓
Logical Backup
        ↓
Dump and Restore
        ↓
Percona XtraDB Cluster
        ↓
Validation
        ↓
Safety Verification
        ↓
Automated Testing
        ↓
CI Validation
        ↓
Monitoring
        ↓
Disaster Recovery Verification
        ↓
Rollback Readiness
        ↓
Operational Runbook
```

The migration workflow has been tested in a controlled Docker environment, validated through automated and manual checks, documented with operational procedures, and prepared with safety, monitoring, recovery, rollback, and migration-state controls.

---

## Repository

GitHub Repository:

https://github.com/tahsinulhoque/mariadb-galera-to-pxc-migration

---

## Status

```text
Project Type: Database Migration Proof of Concept
Migration Method: Dump and Restore
Source: MariaDB Galera Cluster
Target: Percona XtraDB Cluster 8.4

Test Migration: PASS
Validation: PASS
Safety Gates: PASS
Automated Testing: PASS
CI Validation: PASS
Monitoring: PASS
Disaster Recovery Verification: PASS
Rollback Readiness: Documented
Migration State Tracking: Documented

Production Migration: PENDING
```
