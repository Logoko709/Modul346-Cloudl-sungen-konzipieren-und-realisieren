#!/bin/bash

echo "############################################################"
echo "# Test des CSV-to-JSON Conversion Services                 #"
echo "############################################################"

# Variablen
AWS_REGION="us-east-1"
INPUT_BUCKET="inbucketcsvtojson"
OUTPUT_BUCKET="outbucketcsvtojson"
TEST_FILE="test.csv"
EXPECTED_OUTPUT="test.json"

# Schritt 1: Hochladen der Testdatei
echo "Schritt 1: Lade Testdatei ($TEST_FILE) in den Input-Bucket ($INPUT_BUCKET)..."
aws s3 cp $TEST_FILE s3://$INPUT_BUCKET/

if [ $? -eq 0 ]; then
    echo "Datei erfolgreich hochgeladen!"
else
    echo "Fehler beim Hochladen der Datei. Überprüfen Sie Ihre AWS CLI-Konfiguration."
    exit 1
fi

# Schritt 2: Überprüfung des Output-Buckets
echo "Schritt 2: Warten auf die generierte JSON-Datei im Output-Bucket ($OUTPUT_BUCKET)..."
sleep 5  # Optional: Warten, bis die Lambda-Funktion abgeschlossen ist

aws s3 ls s3://$OUTPUT_BUCKET/ | grep $EXPECTED_OUTPUT

if [ $? -eq 0 ]; then
    echo "JSON-Datei gefunden! Lade die Datei herunter..."
    aws s3 cp s3://$OUTPUT_BUCKET/$EXPECTED_OUTPUT ./output.json
    echo "Datei erfolgreich heruntergeladen. Prüfen Sie die Datei mit: cat output.json"
else
    echo "JSON-Datei wurde nicht gefunden. Überprüfen Sie die Logs der Lambda-Funktion."
    exit 1
fi

# Schritt 3: Logs überprüfen
echo "Schritt 3: Anzeigen der Logs der Lambda-Funktion ($LAMBDA_FUNCTION_NAME)..."
aws logs tail /aws/lambda/Csv2JsonService --region $AWS_REGION --follow

echo "############################################################"
echo "# Test abgeschlossen! Überprüfen Sie die JSON-Datei und Logs #"
echo "############################################################"
