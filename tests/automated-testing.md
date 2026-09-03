# Automated Testing

## Objective

Automate the verification of the migrated database and PXC cluster to reduce manual validation effort.

## Automated Tests

The project includes automated tests for:

- Database migration
- PXC cluster validation

## Migration Test

Script:

`tests/migration/test-migration.sh`

The migration test verifies:

- `migration_db` exists.
- Required tables exist.
- Expected row counts are present.

Expected data:

| Table | Expected Rows |
|---|---:|
| users | 5 |
| products | 5 |
| orders | 4 |
| order_items | 5 |

Result:

**AUTOMATED MIGRATION TEST PASSED**

## Validation Test

Script:

`tests/validation/test-validation.sh`

The validation test verifies:

- PXC cluster size is 3.
- Cluster status is `Primary`.
- Node state is `Synced`.
- WSREP is ready.
- `migration_db` exists.

Result:

**AUTOMATED VALIDATION TEST PASSED**

## Test Execution

Migration test:

```bash
bash tests/migration/test-migration.sh
bash tests/validation/test-validation.sh
```
## Overall Result

All implemented automated migration and validation tests passed successfully.
AUTOMATED TESTING: PASS
