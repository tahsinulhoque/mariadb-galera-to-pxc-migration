# Validation Report

## Objective

Validate the migrated `migration_db` database on the Percona XtraDB Cluster (PXC) after the test migration and cutover preparation.

## Cluster Validation

The PXC cluster was checked using the following parameters:

- Cluster Size: 3
- Cluster Status: Primary
- Local State: Synced
- WSREP Ready: ON

Result: PASS

## Database Validation

The `migration_db` database was verified on PXC.

Required tables were checked:

- users
- products
- orders
- order_items

Result: PASS

## Row Count Validation

The migrated data was checked against the source database.

| Table | Expected Rows | Result |
|---|---:|---|
| users | 5 | PASS |
| products | 5 | PASS |
| orders | 4 | PASS |
| order_items | 5 | PASS |

## Data Validation

Data was successfully read from the migrated tables.

Foreign key relationships and table structures were also verified.

Result: PASS

## Final Validation Result

All required validation checks passed successfully.

**Overall Result: PASS**

The PXC cluster is healthy, the migrated database is available, and the expected data is present.