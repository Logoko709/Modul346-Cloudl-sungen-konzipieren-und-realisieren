#!/bin/bash

# Variablen
AWS_REGION="us-east-1"
INPUT_BUCKET="inbucketcsvtojson"
OUTPUT_BUCKET="outbucketcsvtojson"
LAMBDA_FUNCTION_NAME="Csv2JsonService"

echo "### Einrichtung des CSV-to-JSON Conversion Services ###"

# Schritt 1: S3-Buckets erstellen
echo "Erstellen der S3-Buckets ($INPUT_BUCKET und $OUTPUT_BUCKET)..."
aws s3 mb s3://$INPUT_BUCKET --region $AWS_REGION
aws s3 mb s3://$OUTPUT_BUCKET --region $AWS_REGION

# Schritt 2: Lambda-Funktion erstellen
echo "Erstellen der Lambda-Funktion ($LAMBDA_FUNCTION_NAME)..."
zip function.zip lambda_function.py
aws lambda create-function \
    --function-name $LAMBDA_FUNCTION_NAME \
    --runtime python3.9 \
    --role arn:aws:iam::[ACCOUNT_ID]:role/LambdaExecutionRole \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://function.zip \
    --region $AWS_REGION

# Schritt 3: Trigger (S3) hinzufügen
echo "Hinzufügen eines S3-Triggers zur Lambda-Funktion..."
aws lambda add-permission \
    --function-name $LAMBDA_FUNCTION_NAME \
    --action lambda:InvokeFunction \
    --principal s3.amazonaws.com \
    --statement-id s3invoke \
    --source-arn arn:aws:s3:::$INPUT_BUCKET \
    --region $AWS_REGION

aws s3api put-bucket-notification-configuration \
    --bucket $INPUT_BUCKET \
    --notification-configuration file://notification.json

echo "### Einrichtung abgeschlossen ###"

