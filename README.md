## Expenso : A Starting Point Flutter App

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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* Some details around OAuth with PKCE Approach *

There are total 6 steps to use the OAuth `PKCE` approach. This is general and more 
secure than `User Credential` approach.

```dart
// There will be two endoints provided by API owner (here Salesforce)
// A. One to get the authorization code from Authorization endpoint
// B. Once authorization code is received, get the token from token endpoint
String authorizationEndpoint = 'https://login.salesforce.com/services/oauth2/authorize';
String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
  
// Create a connected app in Salesforce and generate these values
const String clientId = 'your_client_id';
const String redirectUri = 'your_redirect_uri';

// 1. Generate a string (can be random as well) called `code verifier`
Random random = Random.secure();
final List<int> codeUnitsForVerifier = List.generate(32, (index) { return random.nextInt(256); });
String codeVerifier =  base64Url.encode(Uint8List.fromList(codeUnitsForVerifier));

// 2. Generate a string called code challenge from this verifier text
List<int> codeUnitsForChallenge = utf8.encode(codeVerifier);
Digest digest = sha256.convert(Uint8List.fromList(codeUnitsForChallenge));
Uint8List bytes = Uint8List.fromList(digest.bytes);
String codeChallenge = String.fromCharCodes(base64Url.encode(bytes));

// 3. Generate Auth endpoint and do a callout (All login requests generally will have content header as `'Content-Type': 'application/x-www-form-urlencoded'`)
String authorizationUrl = '''$authorizationEndpoint?
                              response_type=code&
                              client_id=$clientId&
                              redirect_uri=$redirectUri&      
                              code_challenge=$codeChallenge&  
                              code_challenge_method=S256      
                              ''';

// 4: Get the auth code by opening a WebView OR redirecting the user to the authorization URL
http.Response tokenResponse = await http.post(Uri.parse(authorizationUrl),headers: {'Content-Type': 'application/x-www-form-urlencoded'});
String authorizationCode = tokenResponse.body['code'];

// 5: Use this authorization code in request body to call to token endpoint, this is to get `token` from `code`
// Token endpoint as we mentioned, is already a constant url.
// tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
Map<String, String> tokenRequestBody = {
  'grant_type': 'authorization_code',
  'client_id': clientId,
  'redirect_uri': redirectUri,
  'code': authorizationCode,      
  'code_verifier': codeVerifier, 
};

// 6 : Call token endpoint to get auth token
http.Response tokenResponse = await http.post(Uri.parse(tokenEndpoint),
                                             headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                             body: tokenRequestBody);


// Use auth token further for subsequent requests. Note the content type is 'application/json' here.
// Generate endpoint, header and body and use in request
dynamic header = {'Content-Type': 'application/json'};
dynamic body = {}; // Generate body here as per API
String apiEndpoint = INSTANCE_URL + API_ENDPOINT ; // Generate endpoint URL as per API
http.Response insertResponse = await http.post(Uri.parse(apiEndpoint),
                                             headers: header
                                             body: body);
```

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

** Some details around Composite APIs in Salesforce **
  
Composite APIs are very useful in inserting, updating or deleting data from Salesforce. 
1. Each record requires a unique `referenceId`.
2. The maximum number of records per composite request is 200.

* Sample URL for a sObject : `/services/data/v53.0/composite/tree/<namespace__sObject_api_name>`
* Sample Request for Account object:

```json
{
  "records": [
    {
      "attributes": {
        "type": "<namespace__sObject_api_name>",
        "referenceId": "ref0"
      },
      "Name": "Sample Record 1",
      "Website": "Sample Site 1"
    },
    {
      "attributes": {
        "type": "<namespace__sObject_api_name>",
        "referenceId": "ref1"
      },
      "Name": "Sample Record 2",
      "Website": "Sample Site 2"
    }
  ]
}
```

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

This app works with 2 other apps (see below repos), while installing any one of them, check with the dependencies in versions.

## Compatibility and Dependent Repositories

1. [**Android Broadcast Receiver**](https://github.com/aritram1/phone-app-android-smsforwarder): This component acts as an Android Broadcast Receiver, sending data to Salesforce and forwarding messages to additional recipients if required.

2. [**Flutter Expense Manager App**](https://github.com/aritram1/flutter-expense-manager): This Flutter app serves as an expense manager, providing a user-friendly interface for managing expenses.

3. [**Salesforce Backend**](https://github.com/aritram1/fin-plan-managed): The Salesforce backend is implemented as a packaged app named FinPlan, contributing to the overall backend functionality of the data and server side code.

## Compatible Versions (As of Dec 23, 2023)

### [android-java-smsforwarder](https://github.com/aritram1/android-java-smsforwarder)

- **Stable Version:** [2.0.0](https://github.com/aritram1/android-java-smsforwarder/tree/release/stable/2.0.0)

### [Flutter App](https://github.com/aritram1/flutter-expense-manager)

- **Stable Version:** [1.0.0](https://github.com/aritram1/flutter-expense-manager/tree/release/stable/1.0.0)

### [Salesforce Backend](https://github.com/aritram1/salesforce-finplan-managed)

- **Stable Version:** [1.0.0](https://github.com/aritram1/fin-plan-managed/tree/release/stable/1.0.0)
