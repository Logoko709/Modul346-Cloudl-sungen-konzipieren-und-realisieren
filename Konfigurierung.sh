#!/bin/bash
 
set -e  # Bricht das Skript bei jedem Fehler ab
 
# Überprüfen, ob AWS CLI installiert ist
if ! command -v aws &> /dev/null; then
    echo "Fehler: AWS CLI ist nicht installiert. Bitte installiere AWS CLI, bevor du fortfährst."
    exit 1
fi
 
# IAM-Rollen-ARN aus IAM-Konsole
ROLE_ARN="arn:aws:iam::790850443080:role/LabRole"
 
# Überprüfen, ob die Variable für die IAM-Rolle gesetzt wurde
if [ "$ROLE_ARN" = "<EXISTING_ROLE_ARN>" ]; then
    echo "Fehler: Bitte ersetze <EXISTING_ROLE_ARN> durch den ARN deiner vorhandenen IAM-Rolle."
    exit 1
fi
 
# Variablen für Bucket-Namen (eindeutig durch zufälligen Suffix)
TIMESTAMP=$(date +%s)
REGION="us-east-1" # Passe die Region an deine Bedürfnisse an
INPUT_BUCKET="inputbucketcsvtojson-${TIMESTAMP}"
OUTPUT_BUCKET="outbucketcsvtojson-${TIMESTAMP}"
LAMBDA_FUNCTION_NAME="CsvToJsonConverter2"
ZIP_FILE="lambda_function.zip"
 
echo "Starte die Einrichtung der AWS-Infrastruktur..."
 
# 1. S3-Buckets erstellen
echo "Erstelle S3-Buckets..."
aws s3 mb s3://$INPUT_BUCKET --region $REGION
echo "Input-Bucket $INPUT_BUCKET erstellt."
aws s3 mb s3://$OUTPUT_BUCKET --region $REGION
echo "Output-Bucket $OUTPUT_BUCKET erstellt."
 
# 2. Prüfen, ob das ZIP-File vorhanden ist
if [ ! -f "$ZIP_FILE" ]; then
    echo "Fehler: Die Datei $ZIP_FILE existiert nicht. Bitte erstelle ein ZIP-Archiv mit deinem Lambda-Code."
    exit 1
fi
 
# 3. Lambda-Funktion erstellen
echo "Erstelle Lambda-Funktion..."
LAMBDA_ARN=$(aws lambda create-function \
    --function-name $LAMBDA_FUNCTION_NAME \
    --runtime python3.9 \
    --role $ROLE_ARN \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://$ZIP_FILE \
    --query "FunctionArn" \
    --output text \
    --region $REGION)
 
echo "Lambda-Funktion erstellt: $LAMBDA_ARN"
 
# WICHTIG: Berechtigung hinzufügen, damit S3 diese Lambda-Funktion auslösen darf
echo "Füge Lambda-Berechtigung für S3-Trigger hinzu..."
aws lambda add-permission \
    --function-name $LAMBDA_FUNCTION_NAME \
    --principal s3.amazonaws.com \
    --statement-id s3invoke \
    --action lambda:InvokeFunction \
    --source-arn arn:aws:s3:::$INPUT_BUCKET \
    --region $REGION
 
sleep 5
 
# 4. S3-Trigger für Lambda-Funktion einrichten
echo "Richte S3-Trigger ein..."
aws s3api put-bucket-notification-configuration \
    --bucket $INPUT_BUCKET \
    --notification-configuration file://<(cat <<EOF
{
    "LambdaFunctionConfigurations": [
        {
            "LambdaFunctionArn": "$LAMBDA_ARN",
            "Events": ["s3:ObjectCreated:*"]
        }
    ]
}
EOF
) --region $REGION
 
echo "S3-Trigger für Lambda-Funktion $LAMBDA_FUNCTION_NAME eingerichtet."
 
# 5. Abschlussnachricht
echo "AWS-Infrastruktur erfolgreich eingerichtet!"
echo "Input Bucket: $INPUT_BUCKET"
echo "Output Bucket: $OUTPUT_BUCKET"
echo "Lambda-Funktion: $LAMBDA_FUNCTION_NAME"
