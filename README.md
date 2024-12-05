# Modul346-Cloudl-sungen-konzipieren-und-realisieren

# CSV-to-JSON Converter Lambda

Dieses Repository enthält eine AWS Lambda-Funktion, die CSV-Daten in JSON-Format konvertiert. Die Funktion ist einfach zu verwenden und für automatisierte Workflows in der Cloud optimiert.

## Features

- **Eingabe:** Akzeptiert CSV-Dateien entweder als Base64-codierter Text oder aus einem S3-Bucket.
- **Ausgabe:** Gibt das JSON-Äquivalent der CSV-Daten zurück oder speichert es in einem S3-Bucket.
- **Flexibel:** Unterstützt verschiedene CSV-Formate (mit oder ohne Header).
- **Skalierbar:** Entwickelt für den Einsatz in serverlosen Umgebungen, sodass sie einfach in größere Datenverarbeitungs-Pipelines integriert werden kann.

## Architektur

Die Funktion ist in Node.js (oder Python, je nach deiner Implementierung) geschrieben und nutzt die folgenden AWS-Services:
- **AWS Lambda:** Um die Umwandlung auszuführen.
- **Amazon S3:** Optionaler Speicherort für Eingabe- und Ausgabedateien.

## Voraussetzungen

- AWS-Konto
- IAM-Rolle mit Zugriff auf S3 (falls benötigt)
- Node.js- oder Python-Laufzeitumgebung (für lokale Tests)

## Einrichtung

1. **Repository klonen:**

   ```bash
   git clone https://github.com/dein-benutzername/csv-to-json-lambda.git
   cd csv-to-json-lambda
