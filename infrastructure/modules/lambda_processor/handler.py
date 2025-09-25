def handler(event, context):
    for record in event.get('Records', []):
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"New file uploaded: s3://{bucket}/{key}")
