# CSV to JSON Converter (AWS Lambda)

Dieses Projekt mit dem Namen "Modul346-Cloudlösungen-konzipieren-und-realisieren" wurde von Logoko709 erstellt. Es dient der automatischen Konvertierung von CSV-Dateien in JSON-Dateien, die in einem AWS S3-Bucket hochgeladen werden.

------------------------------------------------------------

Voraussetzungen
- AWS CLI: Installiert und konfiguriert mit Zugangsdaten (aws configure).
- Python 3.x: Lokale Umgebung zur Ausführung der Funktion.
- boto3: Installiere boto3, falls es nicht vorhanden ist:
  pip install boto3

------------------------------------------------------------

Projektstruktur
/Modul346-Cloudlösungen-konzipieren-und-realisieren/
├── lambda_function.py       # Hauptskript für die Lambda-Funktion
├── requirements.txt         # Python-Abhängigkeiten
├── example.csv              # Beispiel-CSV-Datei
├── event.json               # Simuliertes Event für lokale Tests
└── README.md                # Dokumentation

------------------------------------------------------------

Schritte zur Nutzung

1. Klone das Repository mit folgendem Befehl:
   ```
   git clone https://github.com/Logoko709/Modul346-Cloudlösungen-konzipieren-und-realisieren.git
   cd Modul346-Cloudlösungen-konzipieren-und-realisieren
   ```

2. Installiere die Abhängigkeiten:
   ```
   pip install -r requirements.txt
   ```

4. Erstelle die S3-Buckets
   Die Funktion erstellt automatisch die erforderlichen S3-Buckets, falls sie noch nicht existieren:
   Input-Bucket: inputbucketcsvtojson
   Output-Bucket: outbucketcsvtojson

   Alternativ manuell:
   aws s3 mb s3://inputbucketcsvtojson
   aws s3 mb s3://outbucketcsvtojson

5. Lade eine CSV-Datei hoch
   aws s3 cp example.csv s3://inputbucketcsvtojson/

6. Lokale Simulation der Lambda-Funktion

   Erstelle ein Event-JSON (event.json):
   {
       "Records": [
           {
               "s3": {
                   "bucket": {
                       "name": "inputbucketcsvtojson"
                   },
                   "object": {
                       "key": "example.csv"
                   }
               }
           }
       ]
   }

   Führe die Funktion lokal aus:
   python lambda_function.py

7. Prüfe den Output
   Nach der Verarbeitung erscheint die JSON-Datei im Output-Bucket (outbucketcsvtojson).
   Lade sie herunter, um sie zu prüfen:
   aws s3 cp s3://outbucketcsvtojson/example.json ./output.json

------------------------------------------------------------

Beispiel-CSV
id,name,age,city
1,John Doe,29,Zurich
2,Jane Smith,34,Bern
3,Bob Brown,23,Geneva

Erwartetes JSON-Output:
[
    {
        "id": "1",
        "name": "John Doe",
        "age": "29",
        "city": "Zurich"
    },
    {
        "id": "2",
        "name": "Jane Smith",
        "age": "34",
        "city": "Bern"
    },
    {
        "id": "3",
        "name": "Bob Brown",
        "age": "23",
        "city": "Geneva"
    }
]

------------------------------------------------------------

Deployment in AWS

1. Erstelle die Lambda-Funktion
   Code zippen:
   zip lambda_function.zip lambda_function.py

   Lambda-Funktion erstellen:
   aws lambda create-function \
       --function-name CsvToJsonConverter \
       --runtime python3.x \
       --role <IAM_ROLE_ARN> \
       --handler lambda_function.lambda_handler \
       --zip-file fileb://lambda_function.zip

2. Richte den S3-Trigger ein
   - Öffne den S3-Bucket (inputbucketcsvtojson) in der AWS Management Console.
   - Navigiere zu Properties > Event notifications.
   - Erstelle eine Benachrichtigung:
     Event Type: All object create events
     Lambda Function: CsvToJsonConverter

------------------------------------------------------------

Fehlerbehebung

1. AWS CLI ist nicht installiert
   sudo apt update
   sudo apt install awscli

2. Berechtigungsfehler
   Stelle sicher, dass die IAM-Rolle/Lambda-Funktion Zugriff auf S3 hat:
   Erforderliche Berechtigungen:
   s3:GetObject
   s3:PutObject
   s3:ListBucket

------------------------------------------------------------

Autor
Name: Logoko709
Projektname: Modul346-Cloudlösungen-konzipieren-und-realisieren
