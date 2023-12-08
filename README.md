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
