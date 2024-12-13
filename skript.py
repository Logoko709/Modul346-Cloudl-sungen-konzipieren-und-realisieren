import boto3
import csv
import json

s3 = boto3.client('s3')

def create_bucket_if_not_exists(bucket_name, region="eu-central-1"):
    try:
        s3.head_bucket(Bucket=bucket_name)
        print(f"Bucket {bucket_name} existiert bereits.")
    except s3.exceptions.ClientError:
        print(f"Erstelle Bucket {bucket_name}...")
        s3.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={
                'LocationConstraint': region
            }
        )
        print(f"Bucket {bucket_name} erfolgreich erstellt.")

def lambda_handler(event, context):
    # Namen der Buckets definieren
    in_bucket = "inputbucketcsvtojson"
    out_bucket = "outbucketcsvtojson"

    # Überprüfen und Erstellen der Buckets
    create_bucket_if_not_exists(in_bucket)
    create_bucket_if_not_exists(out_bucket)

    # Extrahiere Bucket- und Dateiinformationen aus dem Trigger-Event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']

    try:
        # Lade die CSV-Datei aus dem In-Bucket
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        csv_content = response['Body'].read().decode('utf-8').splitlines()

        # Konvertiere CSV zu JSON
        csv_reader = csv.DictReader(csv_content)
        json_data = [row for row in csv_reader]

        # Speichere die JSON-Datei im Out-Bucket
        json_file_key = file_key.replace(".csv", ".json")
        s3.put_object(
            Bucket=out_bucket,
            Key=json_file_key,
            Body=json.dumps(json_data),
            ContentType='application/json'
        )

        print(f"Erfolgreich konvertiert: {file_key} in {json_file_key}")
    except Exception as e:
        print(f"Fehler beim Verarbeiten der Datei {file_key}: {str(e)}")
