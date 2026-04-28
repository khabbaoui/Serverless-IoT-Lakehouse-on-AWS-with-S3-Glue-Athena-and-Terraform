import json
import boto3
from urllib.parse import unquote_plus

s3 = boto3.client("s3")

REQUIRED_FIELDS = ["device_id", "temperature", "battery_level", "timestamp"]


def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = unquote_plus(record["s3"]["object"]["key"])

        obj = s3.get_object(Bucket=bucket, Key=key)
        content = obj["Body"].read().decode("utf-8")
        data = json.loads(content)

        is_valid = all(field in data and data[field] is not None for field in REQUIRED_FIELDS)

        file_name = key.split("/")[-1]

        if is_valid:
            target_key = f"curated/device_health_validated/{file_name}"
        else:
            target_key = f"errors/invalid_records/{file_name}"

        s3.put_object(
            Bucket=bucket,
            Key=target_key,
            Body=json.dumps(data),
            ContentType="application/json"
        )

        print(f"Processed {key} -> {target_key}")

    return {"statusCode": 200}