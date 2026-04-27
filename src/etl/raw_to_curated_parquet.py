import boto3
import pandas as pd
from io import BytesIO

BUCKET = "serverless-iot-lakehouse-7046eef4"

s3 = boto3.client("s3")

raw_key = "raw/iot_events/sample.json"

obj = s3.get_object(Bucket=BUCKET, Key=raw_key)
df = pd.read_json(obj["Body"], typ="series").to_frame().T

df = df.dropna()
df["temperature_status"] = df["temperature"].apply(
    lambda x: "critical" if x >= 80 else "normal"
)
df["battery_status"] = df["battery_level"].apply(
    lambda x: "low" if x < 20 else "normal"
)

parquet_buffer = BytesIO()
df.to_parquet(parquet_buffer, index=False)

curated_key = "curated/device_health_parquet/data.parquet"

s3.put_object(
    Bucket=BUCKET,
    Key=curated_key,
    Body=parquet_buffer.getvalue()
)

print(f"Curated Parquet written to s3://{BUCKET}/{curated_key}")