# CSV to JSON Conversion Service

Ein vollständig implementierter AWS-basierter Service, der CSV-Dateien automatisch in JSON-Dateien umwandelt. Der Service wurde entwickelt, um durch Hochladen einer CSV-Datei in einen Amazon S3-Bucket eine JSON-Datei zu generieren, die in einem separaten Bucket gespeichert wird.

---

## 📋 **Projektübersicht**
- **Ziel:** Automatisierte Konvertierung von CSV zu JSON mithilfe von AWS Lambda und S3.
- **Komponenten:**
  - **Input-Bucket:** Speichert hochgeladene CSV-Dateien.
  - **Output-Bucket:** Speichert die konvertierten JSON-Dateien.
  - **AWS Lambda-Funktion:** Führt die Konvertierung durch, ausgelöst durch das Hochladen in den Input-Bucket.

---

## 🛠 **Ressourcen**
- **Region:** `us-east-1`
- **Input-Bucket:** `inbucketcsvtojson`
- **Output-Bucket:** `inbucketcsvtojson`
- **Lambda-Funktion:** `Csv2JsonLambdaRole`

---

## 🚀 **Testanleitung**

### **1. Voraussetzungen**
- Zugriff auf AWS mit aktivierten Berechtigungen für S3 und Lambda.
- AWS CLI ist installiert und konfiguriert (optional, falls CLI genutzt wird).

### **2. Schritte zum Testen**

#### **Schritt 1: Hochladen einer CSV-Datei**
1. Öffnen Sie die AWS Management Console.
2. Navigieren Sie zu **Amazon S3** und wählen Sie den Bucket `csv2json-input-bucket`.
3. Laden Sie eine CSV-Datei hoch, z. B. `test.csv` (liegt im Repository bereit).

#### **Schritt 2: Ergebnis überprüfen**
1. Öffnen Sie den Bucket `csv2json-output-bucket`.
2. Suchen Sie nach der JSON-Datei mit dem gleichen Namen wie die hochgeladene CSV-Datei (z. B. `test.json`).
3. Laden Sie die JSON-Datei herunter und überprüfen Sie den Inhalt.

#### **Schritt 3: Logs überprüfen (bei Fehlern)**
1. Öffnen Sie die **AWS CloudWatch-Konsole**.
2. Navigieren Sie zu den Logs der Lambda-Funktion: `/aws/lambda/Csv2JsonService`.
3. Überprüfen Sie die Protokolle auf Fehler oder Warnungen.

---

## 📁 **Beispieldateien**
Im Ordner `test/` finden Sie:
- `test.csv`: Eine Beispieldatei mit folgenden Daten:
  ```csv
  Name,Age,City
  Alice,25,New York
  Bob,30,San Francisco
  Charlie,35,Los Angeles

