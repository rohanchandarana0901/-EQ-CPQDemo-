public class APTSMD_SampleLightningPageController {
    
    public string statusValuesListJSON {get; set;}
    public string statusCategoryValuesListJSON {get; set;}
    public string RecordTypeNamesJSON {get; set;}
   
    public APTSMD_SampleLightningPageController(){
        List<String> statusValuesList= new List<String>();
        List<String> statusCategoryValuesList= new List<String>();
        
        Schema.DescribeFieldResult statusfieldResult = Apttus__APTS_Agreement__c.Apttus__Status__c.getDescribe();
        Schema.DescribeFieldResult statusCategoryfieldResult = Apttus__APTS_Agreement__c.Apttus__Status_Category__c.getDescribe();
        
        List<Schema.PicklistEntry>  ple = statusfieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            statusValuesList.add(pickListVal.getLabel());
        } 
        
        ple.clear();
        ple = statusCategoryfieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            statusCategoryValuesList.add(pickListVal.getLabel());
        }
    
        Map<String, Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName();
        List<String> RecordTypeNames = new List<String>();
        RecordTypeNames.addAll(rtMapByName.keyset()); 
        
        statusValuesListJSON = JSON.serialize(statusValuesList);
        statusCategoryValuesListJSON = JSON.serialize(statusCategoryValuesList);
        RecordTypeNamesJSON = JSON.serialize(RecordTypeNames);
    }   
    
    public static List < AgreementWrapper> getListOfAgreement(String userId, String query) {
        List < AgreementWrapper > result = new List < AgreementWrapper > ();
        //List < Apttus__APTS_Agreement__c > listOfAgreement = [select Id, name, RecordType.Name, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c, CreatedDate, Apttus__Primary_Contact__r.Name, Apttus__FF_Agreement_Number__c, Apttus__Account__r.Id, Apttus__Account__r.Name, Apttus__Status_Category__c, Apttus__Status__c, Apttus__Total_Contract_Value__c from Apttus__APTS_Agreement__c order by CreatedDate desc];
        List < Apttus__APTS_Agreement__c > listOfAgreement = Database.query(query);
        system.debug('##############listOfAgreement' + listOfAgreement);
        if (listOfAgreement != null && listOfAgreement.size() > 0) {
            Integer counter = 0;
            for (Apttus__APTS_Agreement__c agreement: listOfAgreement) {
                counter = counter + 1;
                AgreementWrapper wrapper = new AgreementWrapper();
                wrapper.agreementId = agreement.Id;
                wrapper.agreementNumber = agreement.Apttus__FF_Agreement_Number__c;
                wrapper.agreementName = agreement.name;
                wrapper.primaryContact = agreement.Apttus__Primary_Contact__r.Name;
                wrapper.status = agreement.Apttus__Status__c;
                wrapper.recordTypeName = agreement.RecordType.Name;
                wrapper.contractValue = agreement.Apttus__Total_Contract_Value__c;
                wrapper.startDate = agreement.Apttus__Contract_Start_Date__c;
                wrapper.endDate = agreement.Apttus__Contract_End_Date__c;
                wrapper.createdDate = agreement.CreatedDate;
                wrapper.srNo = counter;
                wrapper.accountId = agreement.Apttus__Account__r.Id;
                wrapper.accountName = agreement.Apttus__Account__r.Name;
                wrapper.category = agreement.Apttus__Status_Category__c;
                result.add(wrapper);
            }
        }
        return result;
    }

    @RemoteAction
    public static String getAgreement(String query) {
        system.debug('####Messsage'+ query);
        String userid = UserInfo.getUserId();
        return JSON.serialize(getListOfAgreement(userid, query));
    }
    
    class AgreementWrapper {
        Integer srNo {get;set;}
        String agreementId {get;set;}
        String agreementName {get;set;}
        String accountId {get;set;}
        String accountName {get;set;}
        String category {get;set;}
        String status {get;set;}
        String primaryContact {get;set;}
        Date startDate {get;set;}
        Date endDate {get;set;}
        DateTime createdDate {get;set;}
        String agreementNumber {get;set;}
        String recordTypeName {get;set;}
        Decimal contractValue {get;set;}
    }
    
    public static List < AccountWrapper > getListOfAccount() {
        List < AccountWrapper > result = new List < AccountWrapper > ();
        List < Account > listOfAccount = [select Id, name from Account order by CreatedDate desc];
        system.debug('##############listOfAgreement' + listOfAccount);
        if (listOfAccount != null && listOfAccount.size() > 0) {
            Integer counter = 0;
            for (Account account: listOfAccount) {
                counter = counter + 1;
                AccountWrapper wrapper = new AccountWrapper();
                wrapper.srNo = counter;
                wrapper.accountId = account.Id;
                wrapper.accountName = account.Name;
                result.add(wrapper);
            }
        }
        return result;
    }
    
    
    @RemoteAction
    public static String getAccounts(){
        return JSON.serialize(getListOfAccount());
    }

    class AccountWrapper {
        Integer srNo {get;set;}
        String accountId {get;set;}
        String accountName {get;set;}
    }
    
    public static List <ContactWrapper> getListOfContact() {
        List <ContactWrapper> result = new List < ContactWrapper > ();
        List <Contact> listOfContact = [select Id, name from Contact order by CreatedDate desc];
        system.debug('##############listOfAgreement' + listOfContact);
        if (listOfContact != null && listOfContact.size() > 0) {
            Integer counter = 0;
            for (Contact contact: listOfContact) {
                counter = counter + 1;
                ContactWrapper wrapper = new ContactWrapper();
                wrapper.srNo = counter;
                wrapper.contactId = contact.Id;
                wrapper.contactName = contact.Name;
                result.add(wrapper);
            }
        }
        return result;
    }
    
    
    @RemoteAction
    public static String getContacts(){
        return JSON.serialize(getListOfContact());
    }

    class ContactWrapper {
        Integer srNo {get;set;}
        String contactId {get;set;}
        String contactName {get;set;}
    }    
}