# Production Safety Gates

## Objective

Define the safety checks that must pass before continuing with the database migration and cutover process.

The safety gate prevents migration activities from continuing when the target PXC cluster is not in a healthy state.

---

## Safety Checks

The production safety gate checks the following conditions:

1. PXC node 1 is running.
2. PXC node 2 is running.
3. PXC node 3 is running.
4. PXC cluster size is 3.
5. PXC cluster status is `Primary`.
6. PXC node state is `Synced`.
7. WSREP is ready.
8. `migration_db` exists.

---

## Safety Gate Decision

The migration can proceed only when all required checks pass.

If any check fails:

- The safety gate returns a failure status.
- The migration must not continue.
- The failed condition must be investigated before proceeding.

---

## Safety Gate Script

The automated safety checks are implemented in:

`migration/production-safety-check.sh`

---

## Expected Successful Result

A successful safety gate should confirm:

- All three PXC nodes are running.
- Cluster size is 3.
- Cluster status is `Primary`.
- Node state is `Synced`.
- WSREP is ready.
- `migration_db` exists.

Final result:

**SAFETY GATE PASSED**

---

## Failure Handling

If any safety check fails, the script returns a non-zero exit status.

Final result:

**SAFETY GATE FAILED**

Migration or cutover must not continue until the failed condition is resolved.

---

## Execution

The safety gate script can be executed from the project root:

```bash
bash migration/production-safety-check.sh
```