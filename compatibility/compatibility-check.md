# DEV-810 — Compatibility Check

## Source Environment

- Database: MariaDB
- Cluster: MariaDB Galera
- Nodes: 3
- Environment: Docker Desktop
- Database: migration_db

## 1. Storage Engines

All application tables are using the InnoDB storage engine.

| Table | Storage Engine |
|---|---|
| users | InnoDB |
| products | InnoDB |
| orders | InnoDB |
| order_items | InnoDB |

## 2. Schema Features

The current schema contains:

- Primary keys
- Foreign keys
- Basic indexes
- Standard VARCHAR, INT, DECIMAL and TIMESTAMP data types

### Foreign Key Relationships

- orders.user_id → users.id
- order_items.order_id → orders.id
- order_items.product_id → products.id

## 3. Triggers

No triggers are currently configured.

## 4. Stored Procedures / Functions

No stored procedures or functions are currently configured.

## 5. Proxy Setup

No proxy is currently configured in the test environment.

The current environment connects directly to the MariaDB Galera nodes.

## 6. Galera Baseline

The source cluster was verified with:

- Cluster size: 3
- Cluster status: Primary

## Conclusion

The current test database uses standard InnoDB tables and basic relational schema features.

No triggers, stored procedures/functions, or proxy configuration are currently present.

Further compatibility validation will be performed during the test PXC setup and migration phase.