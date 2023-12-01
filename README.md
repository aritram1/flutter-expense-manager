# flutter_phone_app

A fun-learn flutter project - This project is a starting point for a Flutter application. As of now this application works as retrieving sms messages from phone, logs into Salesforce and stores them as Salesforce custom object records. It uses the standard composite API (url below) to insert the data. 

Sample composite endpoint : <instance_url>/services/data/v53.0/composite/tree/<object_api_name>
Sample composite request : 
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
                "referenceId": "ref0"
            },
            "Name" : "Sample Record 2",
            "Website" : "Sample Site 2"
        }
    ]
}

The maximum number of records that can be part of a single composite request is 200.

~ Aritra