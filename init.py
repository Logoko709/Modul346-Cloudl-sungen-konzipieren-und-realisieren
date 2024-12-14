import boto3
import csv
import json

s3 = boto3.client('s3')

def create_bucket_if_not_exists(bucket_name, region="eu-central-1"):
    """
    Erstellt einen S3-Bucket, falls er nicht existiert.
    :param bucket_name: Name des Buckets
    :param region: AWS-Region, in der der Bucket erstellt wird
    """
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

def add_s3_trigger(lambda_function_name, bucket_name):
    """
    Fügt einen S3-Trigger hinzu, um die Lambda-Funktion auszulösen, wenn eine Datei hochgeladen wird.
    :param lambda_function_name: Name der Lambda-Funktion
    :param bucket_name: Name des Input-Buckets
    """
    lambda_client = boto3.client('lambda')
    try:
        # Lambda-Berechtigung hinzufügen
        lambda_client.add_permission(
            FunctionName=lambda_function_name,
            StatementId=f"s3-trigger-{bucket_name}",
            Action="lambda:InvokeFunction",
            Principal="s3.amazonaws.com",
            SourceArn=f"arn:aws:s3:::{bucket_name}"
        )

        # S3-Benachrichtigung konfigurieren
        s3.put_bucket_notification_configuration(
            Bucket=bucket_name,
            NotificationConfiguration={
                'LambdaFunctionConfigurations': [
                    {
                        'LambdaFunctionArn': lambda_client.get_function(FunctionName=lambda_function_name)['Configuration']['FunctionArn'],
                        'Events': ["s3:ObjectCreated:*"]
                    }
                ]
            }
        )
        print(f"S3-Trigger für Bucket {bucket_name} erfolgreich hinzugefügt.")
    except Exception as e:
        print(f"Fehler beim Hinzufügen des S3-Triggers: {str(e)}")

def lambda_handler(event, context):
    """
    Hauptfunktion, die durch ein S3-Event ausgelöst wird.
    :param event: Das von S3 ausgelöste Event
    :param context: Lambda-Ausführungskontext
    """
    if 'Records' not in event:
        print("Fehler: Event enthält keine 'Records'.")
        return {
            "statusCode": 400,
            "body": "Invalid event format. 'Records' key is missing."
        }

    # Namen der Buckets definieren
    in_bucket = event['Records'][0]['s3']['bucket']['name']
    out_bucket = "outbucketcsvtojson"  # Hier den Namen deines Out-Buckets einfügen

    # Überprüfen und Erstellen der Buckets
    create_bucket_if_not_exists(in_bucket)
    create_bucket_if_not_exists(out_bucket)

    # Extrahiere Dateiinformationen aus dem Trigger-Event
    file_key = event['Records'][0]['s3']['object']['key']

    try:
        # Lade die CSV-Datei aus dem In-Bucket
        response = s3.get_object(Bucket=in_bucket, Key=file_key)
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

if __name__ == "__main__":
    # Beispiel für das Hinzufügen eines Triggers
    input_bucket = "inputbucketcsvtojson"
    output_bucket = "outbucketcsvtojson"
    lambda_function_name = "your-lambda-function-name"  # Ersetze durch den Namen deiner Lambda-Funktion

    # Buckets erstellen
    create_bucket_if_not_exists(input_bucket)
    create_bucket_if_not_exists(output_bucket)

    # Trigger hinzufügen
    add_s3_trigger(lambda_function_name, input_bucket)

    # Test: Simuliere ein Event
    {
  "Records": [
    {
      "s3": {
        "bucket": {
          "name": "inputbucketcsvtojson"
        },
        "object": {
          "key": "test.csv"
        }
      }
    }
  ]
}


    # Führe die Lambda-Funktion mit dem Test-Event aus
    lambda_handler(test_event, None)
    
