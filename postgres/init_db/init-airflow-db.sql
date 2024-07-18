CREATE DATABASE airflow_db;
CREATE USER airflow WITH PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow;
-- -- PostgreSQL 15 requires additional privileges:
GRANT ALL ON SCHEMA public TO airflow;