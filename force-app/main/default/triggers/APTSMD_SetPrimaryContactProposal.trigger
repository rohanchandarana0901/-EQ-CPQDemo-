/*
    Created By   : Archil Prajapati
    Creted Date  : 1st Jan 2019
    Description  : Sets Primary Contact On New Proposals Or Updated Proposals Where Primary Contact = NULL
----------------------------------------------------------------------------------------------------------
    Created By   : Rahul Sharma
    Creted Date  : 24th Nov 2020
    Description  : Tidy up code, added null handling.
*/

trigger APTSMD_SetPrimaryContactProposal on Apttus_Proposal__Proposal__c (before insert,before update) {
    
    List<id> proposalAccountIds = new List<id>();
    Map<Id,Account> allAccountcontacts = new Map<Id, Account>();
    Contact matchedContact;
    
    //Fetch accountid of the agreement
    for(Apttus_Proposal__Proposal__c proposal : trigger.new){
        if(proposal.Apttus_Proposal__Primary_Contact__c == null){
            proposalAccountIds.add(proposal.Apttus_Proposal__Account__c);
        }
    }
    
    //get contacts linked to that account
    //it returns result in map format. Map between account and its related contacts. 
    if(!proposalAccountIds.isEmpty())
    {
        allAccountcontacts = new Map<ID, Account>([Select id,Name,(select Name from Contacts ORDER by APTSMD_Is_Primary_Contact__c DESC) FROM Account Where ID IN :proposalAccountIds]);// Query
    }
    //fetch default primary contact from presales config settings
    APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting = [select APTSMD_Default_Primary_Contact__c from APTSMD_Apttus_PreSales_Config_Settings2__c];//Query
        
    //get contact which matches the name with the value in the custom setting
    matchedContact = [select id,name from Contact where name =: presalesSetting.APTSMD_Default_Primary_Contact__c Limit 1];//Query
    
    //set the primary contact id in agreement
    for(Apttus_Proposal__Proposal__c proposal : trigger.new){
        if(proposal.Apttus_Proposal__Primary_Contact__c == null && allAccountcontacts.containsKey(proposal.Apttus_Proposal__Account__c) && allAccountcontacts.get(proposal.Apttus_Proposal__Account__c) != null){
            if(!allAccountcontacts.get(proposal.Apttus_Proposal__Account__c).Contacts.isEmpty()){//check if map has contact, then set it
                proposal.Apttus_Proposal__Primary_Contact__c = allAccountcontacts.get(proposal.Apttus_Proposal__Account__c).Contacts[0].id;
            }else{//else resort to default from presales config setting
                if(matchedContact != null){
                    proposal.Apttus_Proposal__Primary_Contact__c = matchedContact.id;
                }else{
                    proposal.Apttus_Proposal__Primary_Contact__c = '';
                }
            }
        }
    }
}