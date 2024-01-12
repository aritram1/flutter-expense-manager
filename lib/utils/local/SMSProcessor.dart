
class SMSMessage {
  String? id;
  String? receivedAt;
  String? transactionDate;
  String? content;
  String? sender;
  String? type;
  String? savingsOrCcAccount;
  double? amountValue;
  String? ccAvailableBalance;
  String? saAvailableBalance;
  String? beneficiary;
  String? paymentVia;
  String? paymentReference;
  bool? createTransaction;
  bool? balanceUpdate;

  SMSMessage({
    this.id,
    this.receivedAt,
    this.transactionDate,
    this.content,
    this.sender,
    this.type,
    this.savingsOrCcAccount,
    this.amountValue,
    this.ccAvailableBalance,
    this.saAvailableBalance,
    this.beneficiary,
    this.paymentVia,
    this.paymentReference,
    this.createTransaction,
    this.balanceUpdate,
  });
}

class BankAccount {
  String? id;
  String? accountCode;
  double? finPlanLastBalance;
  double? finPlanCcAvailableLimit;

  BankAccount({
    this.id,
    this.accountCode,
    this.finPlanLastBalance,
    this.finPlanCcAvailableLimit,
  });
}

class SMSProcessController {
  static List<SMSMessage> processedMessages = [];
  static List<SMSMessage> lastBalanceUpdateSMSList = [];
  static Map<String, BankAccount> allBankAccountsMap = {};

  static void enrichData(List<SMSMessage> allMessages) {
    processedMessages = [];
    lastBalanceUpdateSMSList = [];
    getAllBankAccounts();

    for (SMSMessage sms in allMessages) {
      setTransactionDate(sms);
      setPersonalType(sms);
      setOtpType(sms);
      setCreditDebitTypes(sms);
      processFinalChecks(sms);

      processedMessages.add(sms);
    }

    print('Processed messages: $processedMessages');
  }

  static void setTransactionDate(SMSMessage sms) {
    String? rawDateString = sms.receivedAt?.split(' ')[0];
    if (rawDateString?.contains('-') ?? false) {
      List<String> dateParts = rawDateString!.split('-');
      int yyyy = int.parse(dateParts[0]);
      int mm = int.parse(dateParts[1]);
      int dd = int.parse(dateParts[2]);
      sms.transactionDate = DateTime(yyyy, mm, dd).toIso8601String();
    } else {
      sms.transactionDate = DateTime.fromMillisecondsSinceEpoch(int.parse(rawDateString!)).toIso8601String();
    }
  }

  static void setPersonalType(SMSMessage sms) {
    if (sms.sender?.startsWith('+') ?? false) {
      sms.type = 'personal';
    }
  }

  static void setOtpType(SMSMessage sms) {
    if ((sms.content?.contains('OTP') ?? false) || (sms.sender?.contains('OTP') ?? false) ||
        (sms.content?.contains('Verification') ?? false) || (sms.content?.contains('verification') ?? false)) {
      sms.type = 'otp';
    }
  }

  static void setCreditDebitTypes(SMSMessage sms) {
    if (sms.sender?.contains('HDFC') ?? false) {
      processForHDFCBank(sms);
    } else if (sms.sender?.contains('SBI') ?? false) {
      processForSBIBank(sms);
    } else if (sms.sender?.contains('ICICI') ?? false) {
      processForICICIBank(sms);
    }
  }

  static void processFinalChecks(SMSMessage sms) {
    if (sms.amountValue != null) {
      sms.createTransaction = true;
    }

    if ((sms.ccAvailableBalance?.isNotEmpty ?? false) || (sms.saAvailableBalance?.isNotEmpty ?? false)) {
      sms.balanceUpdate = true;
      lastBalanceUpdateSMSList.add(sms);
    }

    if (sms.type?.isEmpty ?? true) {
      sms.type = 'promotional';
    }
  }

  static void getAllBankAccounts() {
    // Your implementation to get bank accounts
    // For example: allBankAccountsMap = fetchBankAccounts();
  }

  static void processForHDFCBank(SMSMessage sms) {
  List<String> contentArray = sms.content?.split(' ') ?? [];
  if (sms.sender?.contains('HDFC') ?? false) {
    sms.savingsOrCcAccount = allBankAccountsMap['HDFC-SA']?.id;
    
    if (sms.content?.contains('deposited') ?? false) {
      sms.amountValue = double.parse(contentArray[2]);
      sms.type = 'credit';
      sms.saAvailableBalance = sms.content?.split('.Avl bal INR ')[1].split('. Cheque deposits')[0] ?? '';
      
      if (sms.content?.contains('UPI') ?? false) {
        sms.paymentVia = 'UPI';
        String str = sms.content?.split('for')[1].split('.Avl bal')[0] ?? '';
        sms.beneficiary = '${str.split('-')[1]}-${str.split('-')[2]}-${str.split('-')[3]}';
        sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
        sms.paymentReference = str.split('-')[4];
      } else {
        sms.beneficiary = sms.content?.split('for')[1].split('.Avl bal')[0] ?? '';
        sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
      }
    } else if (sms.content?.startsWith('Money Received') ?? false) {
      sms.amountValue = double.parse(contentArray[4]);
      sms.saAvailableBalance = sms.content?.split('Avl bal: INR')[1] ?? '';
      sms.type = 'credit';
      
      String str = sms.content?.split('Avl bal: INR')[0].split('by')[1].replaceAll('(', '').replaceAll(')', '') ?? '';
      sms.beneficiary = str.split('IMPS Ref No. ')[0];
      sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
      
      if (sms.content?.contains('IMPS') ?? false) {
        sms.paymentVia = 'IMPS';
        sms.paymentReference = str.split('IMPS Ref No. ')[1];
      }
    } else if ((sms.content?.contains('debited from a/c **9560') ?? false) && (sms.content?.contains('UPI') ?? false)) {
      sms.amountValue = double.parse(contentArray[3]);
      sms.type = 'debit';
      sms.paymentVia = 'UPI';
      
      String content = sms.content?.replaceAll('(', '').replaceAll(')', '') ?? '';
      sms.beneficiary = content.split('to ')[1].split('. Not you?')[0].split('UPI Ref No ')[0];
      sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
      
      String paymentReferenceString = sms.content?.replaceAll('(', 'START_BRACKET').replaceAll(')', 'END_BRACKET') ?? '';
      sms.paymentReference = paymentReferenceString.split('START_BRACKET')[1].split('END_BRACKET')[0].replaceAll('UPI Ref No.', '').trim();
    } else if ((sms.content?.startsWith('Money Transfer:Rs') ?? false) && (sms.content?.contains('UPI') ?? false)) {
      sms.amountValue = double.parse(contentArray[2]);
      sms.type = 'debit';
      sms.paymentVia = 'UPI';
      sms.paymentReference = sms.content?.split(' UPI:')[1].split('Not you?')[0] ?? '';
      sms.beneficiary = sms.content?.split(' UPI')[0].split(' to ')[1] ?? '';
      sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
    } else if (sms.content?.startsWith('Available Bal in HDFC Bank A/c XX9560 as on') ?? false) {
      sms.saAvailableBalance = contentArray[12].substring(0, contentArray[12].length - 1) ?? '';
      sms.saAvailableBalance = sms.saAvailableBalance?.replaceAll('.Cheque', '') ?? ''; // further check added
    } else if (sms.content?.startsWith('Available Bal in HDFC Bank A/c XX9560 on') ?? false) {
      sms.saAvailableBalance = contentArray[10].substring(0, contentArray[10].length - 1) ?? '';
      sms.saAvailableBalance = sms.saAvailableBalance?.replaceAll('.Cheque', '') ?? ''; // further check added
    }
  }
}

  static void processForSBIBank(SMSMessage sms) {
  List<String> contentArray = sms.content?.split(' ') ?? [];
  sms.savingsOrCcAccount = allBankAccountsMap['SBI-SA']?.id;
  
  if (sms.content?.contains('Your a/c no. XXXXXXXX6414 is credited by') ?? false) {
    sms.amountValue = double.parse(contentArray[9].replaceAll('Rs.', ''));
    sms.type = 'credit';
    
    String modifiedContent = sms.content?.replaceAll('(', 'START_BRACKET').replaceAll(')', 'END_BRACKET') ?? '';
    sms.beneficiary = modifiedContent.split('by')[2].split('START_BRACKET')[0] ?? '';
    sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
    
    if (modifiedContent.contains('IMPS')) {
      sms.paymentVia = 'IMPS';
      sms.paymentReference = modifiedContent.split('START_BRACKET')[1].split('END_BRACKET')[0].replaceAll('IMPS Ref no', '').trim();
    }
  } else if (sms.content?.contains('Your a/c no. XXXXXXXX6414 is debited for') ?? false) {
    sms.amountValue = double.parse(contentArray[9].replaceAll('Rs.', ''));
    sms.beneficiary = sms.content?.split('and')[1].split('credited')[0].trim() ?? '';
    sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
    sms.type = 'debit';
  } else if (sms.content?.contains('withdrawn at SBI ATM') ?? false) {
    sms.amountValue = double.parse(contentArray[3].replaceAll('Rs.', ''));
    sms.beneficiary = 'Self - ATM';
    sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
    sms.saAvailableBalance = contentArray[18].replaceAll('Rs.', '');
    
    if (sms.saAvailableBalance?.endsWith('.') ?? false) {
      sms.saAvailableBalance = sms.saAvailableBalance?.substring(0, sms.saAvailableBalance!.length - 1) ?? '';
    }
    
    sms.paymentReference = contentArray[15];
    
    if (sms.paymentReference?.endsWith('.') ?? false) {
      sms.paymentReference = sms.paymentReference?.substring(0, sms.paymentReference!.length - 1) ?? '';
    }
    
    sms.paymentVia = 'ATM';
    sms.type = 'debit';
  }
}

static void processForICICIBank(SMSMessage sms) {
  List<String> contentArray = sms.content?.split(' ') ?? [];
  // Credit card blocks
  if (sms.content?.contains('spent on ICICI Credit Card XX9006') ?? false) {
    sms.savingsOrCcAccount = allBankAccountsMap['ICICI-CC']?.id;
    sms.type = 'debit';
    sms.beneficiary = sms.content?.split('at')[1].split('Avl Lmt')[0] ?? '';
    sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
    sms.amountValue = double.parse(contentArray[1]);
    sms.ccAvailableBalance = sms.content?.split('Avl Lmt: INR')[1].split('To dispute')[0] ?? '';
  } else if (sms.content?.contains('received on your ICICI Bank Credit Card Account 4xxx9006') ?? false) {
    sms.savingsOrCcAccount = allBankAccountsMap['ICICI-CC']?.id;
    sms.type = 'credit';
    sms.amountValue = double.parse(contentArray[5]);
    sms.beneficiary = 'ICICI Bank Credit Card Account 4xxx9006';
    sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
  }
  // Savings account block
  else if (sms.content?.startsWith('ICICI Bank Account XX360 credited') ?? false) {
    sms.savingsOrCcAccount = allBankAccountsMap['ICICI-SA']?.id;
    sms.type = 'credit';
    sms.amountValue = double.parse(contentArray[5]);
    
    if (sms.content?.contains('UPI') ?? false) {
      sms.paymentVia = 'UPI';
    } else if (sms.content?.contains('IMPS') ?? false) {
      sms.paymentVia = 'IMPS';
      
      String beneficiaryAndReferenceString = sms.content?.split('Info')[1].split('Available')[0].replaceAll('.', '') ?? '';
      sms.paymentReference = beneficiaryAndReferenceString.split('-')[1];
      sms.beneficiary = beneficiaryAndReferenceString.split('-')[2];
      sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
      
      if (sms.content?.contains('Available Balance is Rs.') ?? false) {
        String availableBalanceString = sms.content?.split('Available Balance is Rs.')[1] ?? '';
        sms.saAvailableBalance = availableBalanceString.substring(0, availableBalanceString.length - 1).replaceAll(',', '').trim();
      }
    }
  } else if (sms.content?.startsWith('ICICI Bank Acct XX360 debited with') ?? false) {
    sms.savingsOrCcAccount = allBankAccountsMap['ICICI-SA']?.id;
    sms.type = 'debit';
    sms.amountValue = double.parse(contentArray[7]);
    
    if (sms.content?.contains('UPI') ?? false) {
      sms.paymentVia = 'UPI';
    }
    if (sms.content?.contains('IMPS') ?? false) {
      sms.paymentVia = 'IMPS';
      sms.paymentReference = sms.content?.split('IMPS:')[1].split('. Call ')[0] ?? '';
      sms.beneficiary = sms.content?.split('credited.')[0].split('&')[1] ?? '';
      sms.beneficiary = toCamelCase(sms.beneficiary ?? ''); // convert to camel case for better readability
    }
    if (sms.content?.contains('RTGS') ?? false) {
      sms.paymentVia = 'RTGS';
    }
  }
}
}

class FinPlanException implements Exception {
  final String message;
  FinPlanException(this.message);
}

void main() {
  List<SMSMessage> allMessages = []; // Populate with your SMS data
  SMSProcessController.enrichData(allMessages);
}

String toCamelCase(String inputString) {
  try {
    List<String> modifiedWords = [];

    inputString = inputString.trim();

    // Split the string into words
    List<String> words = inputString.trim().split(' ');

    for (String word in words) {
      word = word.trim(); // trim the whitespaces
      if (word.length == 1) {
        modifiedWords.add(word.toUpperCase()); // if there is only one character in the word
      } else if (word.length > 1) {
        // if there are at least 2 characters in a word
        String firstAlphabet = word.substring(0, 1).toUpperCase();
        String rest = word.substring(1, word.length).toLowerCase();
        modifiedWords.add(firstAlphabet + rest);
      }
    }

    // Join the words back together
    return modifiedWords.join(' ');
  } catch (e) {
    throw FinPlanException(e.toString());
  }
}
