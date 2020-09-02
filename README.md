# Parking Cloud Application
The application has the ability to download data on parking sensors (CSV File) and display them in a table. It is possible to update the current data. 

## Correctness
The app has the following checks:
1. Checks empty fields in sensor data
2. Checks the required number of fields
3. Checks for duplicates when adding new data
4. Checks for duplicates when updating existing data
## Features
Application uses:
1. Custom Objects with relationships: Base_Station__c, Sensor__c
2. Apex, SOQL queries
3. Unit-test (coverage: 100%)
## Sample input
correctData.csv
## User interface
view.png
