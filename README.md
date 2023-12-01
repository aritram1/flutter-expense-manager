# flutter_phone_app

A fun-learn Flutter project. This application works as follows:

1. Retrieves SMS messages from the phone.
2. Logs into Salesforce and stores them as Salesforce custom object records.
3. Uses the standard composite API (URL below) to insert the data.

**Sample Composite Endpoint:** `<instance_url>/services/data/v53.0/composite/tree/<object_api_name>`

**Sample Composite Request:**
```json
{
    "records" : [
        {
            "attributes": {
                "type": "<object_api>",
                "referenceId": "ref0"
            },
            "Name" : "Sample Record 1",
            "Website" : "Sample Site 1"
        },
        {
            "attributes": {
                "type": "<object_api>",
                "referenceId": "ref1"
            },
            "Name" : "Sample Record 2",
            "Website" : "Sample Site 2"
        }
    ]
}
