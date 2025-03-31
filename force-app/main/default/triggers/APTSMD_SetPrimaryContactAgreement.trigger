/*
    Created By   : Archil Prajapati
    Creted Date  : 1st Jan 2019
    Description  : Sets Primary Contact On New Agreements Or Updated Agreements Where Primary Contact = NULL
-----------------------------------------------------------------------------------------------------------
    Created By   : Rahul Sharma
    Creted Date  : 24th Nov 2020
    Description  : Tidy up code, added null handling.
*/

trigger APTSMD_SetPrimaryContactAgreement on Apttus__APTS_Agreement__c (before insert,before update) {
    
    List<id> agreementAccountIds = new List<id>();
    Map<Id,Account> allAccountcontacts = new Map<Id,Account>();
    List<Contact> matchedContact;
    Map<id,id> primaryContactMap;
    
    //Fetch accountid of the agreement
    for(Apttus__APTS_Agreement__c agmnt : trigger.new){
        if(agmnt.Apttus__Primary_Contact__c == null){
            agreementAccountIds.add(agmnt.Apttus__Account__c);
        }
        //below snippet added by vivek to set TAV 0 if it is null to resolve Intelligent Import Merge field issue; Dt:24 Nov 2021
        if(agmnt.Apttus__Status_Category__c == 'Import' && agmnt.Apttus__Total_Contract_Value__c == null){
            agmnt.Apttus__Total_Contract_Value__c = 0;
        }
    }
    
    //get contacts linked to that account
    //it returns result in map format. Map between account and its related contacts.
    if(!agreementAccountIds.isEmpty())
    { 
       allAccountcontacts = new Map<ID, Account>([Select id,Name,(select Name from Contacts ORDER by APTSMD_Is_Primary_Contact__c DESC) FROM Account where ID IN :agreementAccountIds]);// Query
    }
    //fetch default primary contact from presales config settings
    //below line changed by VP to support orchestrate setup process object- single object throws an error while executing test class ; 23rd Nov 2021
    List<APTSMD_Apttus_PreSales_Config_Settings2__c> presalesSetting = [select APTSMD_Default_Primary_Contact__c from APTSMD_Apttus_PreSales_Config_Settings2__c];//Query
        
    //set the primary contact id in agreement
    for(Apttus__APTS_Agreement__c agmnt : trigger.new){
        if(agmnt.Apttus__Primary_Contact__c == null && allAccountcontacts.containsKey(agmnt.Apttus__Account__c) && allAccountcontacts.get(agmnt.Apttus__Account__c) != null){
            if(!allAccountcontacts.get(agmnt.Apttus__Account__c).Contacts.isEmpty()){//check if map has contact, then set it
                agmnt.Apttus__Primary_Contact__c = allAccountcontacts.get(agmnt.Apttus__Account__c).Contacts[0].id;
            }else{//else resort to default from presales config setting
                if(presalesSetting.size() > 0){
                    matchedContact = [select id,name from Contact where name =: presalesSetting[0].APTSMD_Default_Primary_Contact__c Limit 1];
                    if(!matchedContact.isEmpty()){
                        agmnt.Apttus__Primary_Contact__c = matchedContact[0].id;
                    }
                }
                else{
                    agmnt.Apttus__Primary_Contact__c = '';
                }
            }
        }
    }
}