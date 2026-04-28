import boto3
import pandas as pd
from io import BytesIO
import os

BUCKET = os.getenv("BUCKET_NAME")


s3 = boto3.client("s3")

raw_key = "raw/iot_events/sample.json"

obj = s3.get_object(Bucket=BUCKET, Key=raw_key)
df = pd.read_json(obj["Body"], typ="series").to_frame().T

# Cleaning
df = df.dropna()

# Add missing fields for better domain logic
if "device_type" not in df.columns:
    df["device_type"] = "industrial_sensor"

# Convert timestamp
df["event_timestamp"] = pd.to_datetime(df["timestamp"], utc=True)

# Add partitions
df["year"] = df["event_timestamp"].dt.year
df["month"] = df["event_timestamp"].dt.month.astype(str).str.zfill(2)
df["day"] = df["event_timestamp"].dt.day.astype(str).str.zfill(2)

# Business logic
df["temperature_status"] = df["temperature"].apply(
    lambda x: "critical" if x >= 80 else "normal"
)

df["battery_status"] = df["battery_level"].apply(
    lambda x: "low" if x < 20 else "normal"
)

df["vibration_status"] = df["vibration"].apply(
    lambda x: "high" if x >= 0.7 else "normal"
)

df["maintenance_risk"] = df.apply(
    lambda row: "high"
    if row["temperature_status"] == "critical"
    or row["battery_status"] == "low"
    or row["vibration_status"] == "high"
    else "low",
    axis=1
)

# Write parquet to partitioned S3 path
device_type = df["device_type"].iloc[0]
year = df["year"].iloc[0]
month = df["month"].iloc[0]
day = df["day"].iloc[0]

curated_key = (
    f"curated/device_health_parquet/"
    f"device_type={device_type}/"
    f"year={year}/month={month}/day={day}/"
    f"data.parquet"
)

parquet_buffer = BytesIO()
df.drop(columns=["year", "month", "day"]).to_parquet(parquet_buffer, index=False)

s3.put_object(
    Bucket=BUCKET,
    Key=curated_key,
    Body=parquet_buffer.getvalue()
)

print(f"Partitioned Parquet written to s3://{BUCKET}/{curated_key}")