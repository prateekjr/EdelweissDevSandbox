// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);


Account acc = [select id, name, GWM_Online_Id__c from account where name='New Family'];
acc.GWM_Online_Id__c = '4567';
update acc;


Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();