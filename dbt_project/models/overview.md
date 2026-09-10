{% docs __overview__ %}

# dbt Production Framework (Enterprise DW)

Production-grade analytics engineering framework built with **dbt**, **PostgreSQL**, **Docker**, and **GitHub Actions CI/CD**.

---

### Architecture & Pipeline Flow

```text
Source Seeds / Ingestion
        ↓
Staging Layer (`stg_*`)  → Deduplication, data casting, schema validation
        ↓
Core Star Schema:
   ├── Dimensions (`d_*`)  → Master entities, business attributes, logic
   └── Facts (`f_*`)       → Transactional records, margins, unit economics
```

### Framework Standards
1. **Zero Hardcoded Secrets**: Parameterized via environment variables and GitHub Actions secrets.
2. **Quality Gates**: Continuous integration with schema tests, uniqueness checks, and referential integrity constraints.
3. **Automated Documentation**: Static documentation and DAG lineage graph generated on every commit and served via NGINX.

{% enddocs %}
