# Stage 1: Build, run tests, and compile static doc artifacts
FROM python:3.11-slim AS builder

WORKDIR /usr/app

# 1. Install dependencies first for Docker layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Copy dbt project (changes to SQL/YAML won't re-run pip install)
COPY dbt_project/ ./dbt_project/
WORKDIR /usr/app/dbt_project

ARG DB_HOST
ARG DB_PORT=5432
ARG DB_NAME
ARG DB_SCHEMA=analytics

ENV DB_HOST=${DB_HOST} \
    DB_PORT=${DB_PORT} \
    DB_NAME=${DB_NAME} \
    DB_SCHEMA=${DB_SCHEMA}

# DB_USER/DB_PASSWORD are mounted as BuildKit secrets (not ARG/ENV) so they
# never get written into an image layer, `docker history`, or the build cache.
RUN --mount=type=secret,id=db_user \
    --mount=type=secret,id=db_password \
    export DB_USER="$(cat /run/secrets/db_user)" && \
    export DB_PASSWORD="$(cat /run/secrets/db_password)" && \
    dbt seed --profiles-dir . && \
    dbt run --profiles-dir . && \
    dbt test --profiles-dir . && \
    dbt docs generate --profiles-dir .

# Stage 2: Serve via Nginx
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /usr/app/dbt_project/target/index.html /usr/share/nginx/html/index.html
COPY --from=builder /usr/app/dbt_project/target/manifest.json /usr/share/nginx/html/manifest.json
COPY --from=builder /usr/app/dbt_project/target/catalog.json /usr/share/nginx/html/catalog.json

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]