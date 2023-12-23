## Flutter Phone App: A Starting Point

This project is a starting point for a Flutter application designed to:

* Fetch SMS messages from your phone.
* Connect to Salesforce.
* Store retrieved SMS data as custom object records within Salesforce.
* Leverage the standard composite API for efficient data insertion.

Here's a breakdown of the functionality:

**Features:**

* Retrieves SMS messages from your device.
* Establishes a connection to your Salesforce account.
* Converts fetched SMS data into Salesforce custom object record format.
* Utilizes the standard composite API for bulk data insertion into Salesforce.

**Composite API Details:**

* Sample URL: `/services/data/v53.0/composite/tree/<object_api_name>`
* Sample Request:

```json
{
  "records": [
    {
      "attributes": {
        "type": "<object_api>",
        "referenceId": "ref0"
      },
      "Name": "Sample Record 1",
      "Website": "Sample Site 1"
    },
    {
      "attributes": {
        "type": "<object_api>",
        "referenceId": "ref1"
      },
      "Name": "Sample Record 2",
      "Website": "Sample Site 2"
    }
  ]
}
```

**Important Notes:**

* Each record requires a unique `referenceId`.
* The maximum number of records per composite request is 200.

This project provides a solid foundation for further development and customization to suit your specific needs.

========================================================================================

## Compatibility and Dependent Repositories

1. [**Android Broadcast Receiver**](https://github.com/aritram1/phone-app-android-smsforwarder): This component acts as an Android Broadcast Receiver, sending data to Salesforce and forwarding messages to additional recipients if required.

2. [**Flutter Expense Manager App**](https://github.com/aritram1/flutter-expense-manager): This Flutter app serves as an expense manager, providing a user-friendly interface for managing expenses.

3. [**Salesforce Backend**](https://github.com/aritram1/fin-plan-managed): The Salesforce backend is implemented as a packaged app named FinPlan, contributing to the overall backend functionality of the data and server side code.

## Compatible Versions (As of Dec 23, 2023)

### [phone-app-android-smsforwarder](https://github.com/aritram1/phone-app-android-smsforwarder)

- **Stable Version:** [2.0.0](https://github.com/aritram1/android-java-smsforwarder/tree/release/stable/2.0.0)

### [Flutter App](https://github.com/aritram1/flutter-expense-manager)

- **Stable Version:** [1.0.0](https://github.com/aritram1/flutter-expense-manager/tree/release/stable/1.0.0)

### [Salesforce Backend](https://github.com/aritram1/salesforce-finplan)

- **Stable Version:** [1.0.0](https://github.com/aritram1/fin-plan-managed/tree/release/stable/1.0.0)