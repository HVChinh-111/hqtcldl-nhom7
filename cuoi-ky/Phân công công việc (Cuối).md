## 1. Sử dụng GG BigQuery => Triển khai data warehouse: Đăng (23h59 t7 ngày 11/04)
- Script sinh dim_date lên DW.
## 2. Load dữ liệu từ SQL Local lên GG BigQuery: Cường (21h00 t4 ngày 15/04)
CÁCH (CHUẨN DATA ENGINEER – không dùng CSV)
🚀 Flow:
SQL Server → Python → Parquet → Google Cloud Storage → BigQuery
🔹 Bước 1: Cài thư viện Python
pip install pandas pyarrow google-cloud-bigquery
🔹 Bước 2: Extract từ SQL Server
import pandas as pd
import pyodbc

conn = pyodbc.connect(
    "DRIVER={SQL Server};SERVER=localhost;DATABASE=btl_database1;Trusted_Connection=yes;"
)

query = "SELECT * FROM dbo.encounters"
df = pd.read_sql(query, conn)
🔹 Bước 3: Convert → Parquet
df.to_parquet("data.parquet", index=False)
🔹 Bước 4: Upload lên Google Cloud Storage

Dùng CLI:

gsutil cp data.parquet gs://your-bucket/
🔹 Bước 5: Load vào BigQuery
bq load \
--source_format=PARQUET \
your_dataset.encounters \
gs://your-bucket/data.parquet

## 3. Power BI: Hiền 


## 4. Hoàn thiện báo cáo: Chính (23h59 CN ngày 12/04)

## 5. Bảo vệ
- Thuyết trình: Biên