/************************************************************* 
@Name: APTSMD_agreementTreeViewController 
@Author: Akshay Antrolkar (Apttus Developer)
@CreateDate:  26th Jun, 2018
@Description: Class for Custom Agreement Hierarchy Page
******************************************************************/  

Global with sharing class APTSMD_agreementTreeViewController{
    Global List<accountWrapper> Agreements {get;set;} // List of parent Account wrapper and their childs
    Global Map<id,List<Apttus__APTS_Agreement__c>> childMap {get;set;}
    Global List<Apttus__APTS_Agreement__c> listAllAgreements {get;set;}
    Global Map<id,Apttus__APTS_Agreement__c> allagreements {get;set;}
    Global string accountsJSON {get;set;}
    Global string agreementFieldsJSON{get;set;}
    Global string agreementDateFieldsJSON{get;set;}
    public Map<String,String> typeAPIMap = new Map<String,String>();
    Global string agreementDefaultFieldsJSON{get;set;}
    Global Map<String, Schema.SObjectField> AgreementschemaFieldMap{get;set;}
    public List<fieldWrapper> listFieldWrapper;
    public List<fieldWrapper> listDefaultFieldWrapper;
    Global Id accid {get; set;}
    public String accountName {get; set;}
    public String backlink {get; set;}
    public String retURL {get; set;}
    public String instanceURL {get; set;}
    public List<string> defaultColumns;
    public List<string> defaultColumns1;
    public List<Account> listAccounts;
    Global APTSMD_agreementTreeViewController(ApexPages.standardController controller){
        accid = controller.getRecord().Id;
        listAccounts = new List<Account> ();
        listAccounts = [Select Id, Name from Account where Id=:accid];
        if(!listAccounts.isEmpty())
        {
            accountName = listAccounts[0].Name;
        }
        
        Agreements = new list<accountWrapper>();
        defaultColumns1 = new List<String> {'Name','Apttus__FF_Agreement_Number__c','Apttus__Agreement_Number__c','RecordTypeId','Apttus__Contract_Start_Date__c','Apttus__Contract_End_Date__c','Apttus__Status_Category__c','Apttus__Status__c','Apttus__Total_Contract_Value__c'};
        defaultColumns = new List<String> ();
        listAllAgreements = new List<Apttus__APTS_Agreement__c> ();
        allagreements = new Map<Id,Apttus__APTS_Agreement__c> ();
        listDefaultFieldWrapper = new List<fieldWrapper> ();
        if(!listAccounts.isEmpty())
        {
            List<String> selectedFields = new List<String>(defaultColumns1);
            selectedFields.add('Apttus__Parent_Agreement__c');
            listAllAgreements = (list<Apttus__APTS_Agreement__c>)getListWSelectedFields('Apttus__APTS_Agreement__c','Apttus__Account__c=\''+accid+'\'',0,'RecordType.Name,','Apttus__Agreement_Number__c ','Apttus__Version_Number__c',selectedFields);
        }
        if(!listAllAgreements.isEmpty())
        {
            for(Apttus__APTS_Agreement__c eachAg : listAllAgreements)
            {
                allagreements.put(eachAg.Id,eachAg);
            }
        }
        if(!defaultColumns1.isEmpty())
        {
            for(String eachDefaultColumn : defaultColumns1)
            {
                defaultColumns.add(eachDefaultColumn.toLowerCase());
            }
        }
        childMap = new Map<id,List<Apttus__APTS_Agreement__c>>();
        AgreementschemaFieldMap = getAllMetaDataFields('Apttus__APTS_Agreement__c');
        listFieldWrapper = new List<fieldWrapper> ();
        if(!defaultColumns.isEmpty())
        {
            for(String eachDefCol : defaultColumns)
            {
                
                if(AgreementschemaFieldMap.containsKey(eachDefCol) && eachDefCol != 'apttus__agreement_number__c')
                {
                    listDefaultFieldWrapper.add(new fieldWrapper (String.valueOf(AgreementschemaFieldMap.get(eachDefCol)),AgreementschemaFieldMap.get(eachDefCol).getDescribe().getLabel(),String.valueOf(AgreementschemaFieldMap.get(eachDefCol).getDescribe().getType()),(boolean)AgreementschemaFieldMap.get(eachDefCol).getDescribe().isNameField()));
                }
                
            }
        }
        for(String fieldAPI : AgreementschemaFieldMap.Keyset()){

            fieldWrapper fieldWrap = new fieldWrapper (String.valueOf(AgreementschemaFieldMap.get(fieldAPI)),AgreementschemaFieldMap.get(fieldAPI).getDescribe().getLabel(),String.valueOf(AgreementschemaFieldMap.get(fieldAPI).getDescribe().getType()),AgreementschemaFieldMap.get(fieldAPI).getDescribe().isNameField());
            listFieldWrapper.add(fieldWrap);
        }
        
        for(String fieldAPI : AgreementschemaFieldMap.Keyset()){
        
            if(String.valueOf(AgreementschemaFieldMap.get(fieldAPI).getDescribe().getType()) == 'DATE'){
                typeAPIMap.put(String.valueOf(AgreementschemaFieldMap.get(fieldAPI)),String.valueOf(AgreementschemaFieldMap.get(fieldAPI).getDescribe().getType()));
            }
        }
        
        agreementDateFieldsJSON = JSON.serialize(typeAPIMap);
        agreementFieldsJSON=JSON.serialize(listFieldWrapper);
        agreementDefaultFieldsJSON=JSON.serialize(listDefaultFieldWrapper);
        
    }
    
    @RemoteAction @ReadOnly
    global static List<accountWrapper> getUpdatedAgreements(String selectedFieldsStr, String accid){
        
        
        
        List<String> selectedFields = selectedFieldsStr.split('#');
        selectedFields.add('Apttus__Parent_Agreement__c');
        selectedFields.add('Apttus__Agreement_Number__c');
        List<Apttus__APTS_Agreement__c> listAllAgreements = (list<Apttus__APTS_Agreement__c>)getListWSelectedFields('Apttus__APTS_Agreement__c','Apttus__Account__c=\''+accid+'\'',0,'RecordType.Name,','Apttus__Agreement_Number__c ','Apttus__Version_Number__c',selectedFields);
          
        Map<id,Apttus__APTS_Agreement__c> allagreements = new Map<id,Apttus__APTS_Agreement__c>();
        Map<id,List<Apttus__APTS_Agreement__c>> childMap = new Map<id,List<Apttus__APTS_Agreement__c>>();
        List<accountWrapper> Agreements = New List<accountWrapper>();
        
        if(!listAllAgreements.isEmpty())
        {
            for(Apttus__APTS_Agreement__c eachAg : listAllAgreements)
            {
                allagreements.put(eachAg.Id,eachAg);
            }
        }
        
         for(id agridOuter : allagreements.keyset()){
            Apttus__APTS_Agreement__c agridOuterAgr = allagreements.get(agridOuter);
            for(id agridInner : allagreements.keyset()){
                Apttus__APTS_Agreement__c agridInnerAgr = allagreements.get(agridInner);
                Decimal agrInnerNumber = decimal.valueOf(agridInnerAgr.Apttus__FF_Agreement_Number__c);
                Decimal agrOuterNumber = decimal.valueOf(agridOuterAgr.Apttus__FF_Agreement_Number__c);
                if((agridOuterAgr.Apttus__Agreement_Number__c == agridInnerAgr.Apttus__Agreement_Number__c) && ((agrInnerNumber - 00000000.1) == agrOuterNumber)){
                    agridInnerAgr.Apttus__Parent_Agreement__c = agridOuterAgr.Id; 
                }
            }
        }
        
        for(id agreeid : allagreements.keyset()){
            Apttus__APTS_Agreement__c thisagreement = allagreements.get(agreeid);
            if(childMap.get(thisagreement.Apttus__Parent_Agreement__c)==NULL){
                childMap.put(thisagreement.Apttus__Parent_Agreement__c,new List<Apttus__APTS_Agreement__c>());
            }
            childMap.get(thisagreement.Apttus__Parent_Agreement__c).add(thisagreement);
        }
        for(id agrId : allagreements.keyset()){
            Integer levelCount = 1;
            Apttus__APTS_Agreement__c thisagreement = allagreements.get(agrId);
            if(thisagreement.Apttus__Parent_Agreement__c==NULL){
                boolean expand = false;
                AccountWrapper aw = new AccountWrapper(thisagreement,levelCount,expand,'white');
                aw.childagreements = getchildwrappersetSt(thisagreement,levelCount,childMap);
                Agreements.add(aw);
            }
        }
        return Agreements;
    }
    
    Global void init ()
    {
       for(id agridOuter : allagreements.keyset()){
            Apttus__APTS_Agreement__c agridOuterAgr = allagreements.get(agridOuter);
            for(id agridInner : allagreements.keyset()){
                Apttus__APTS_Agreement__c agridInnerAgr = allagreements.get(agridInner);
                Decimal agrInnerNumber = decimal.valueOf(agridInnerAgr.Apttus__FF_Agreement_Number__c);
                Decimal agrOuterNumber = decimal.valueOf(agridOuterAgr.Apttus__FF_Agreement_Number__c);
                if((agridOuterAgr.Apttus__Agreement_Number__c == agridInnerAgr.Apttus__Agreement_Number__c) && ((agrInnerNumber - 00000000.1) == agrOuterNumber)){
                    agridInnerAgr.Apttus__Parent_Agreement__c = agridOuterAgr.Id; 
                }
            }
        }
 
        for(id agreeid : allagreements.keyset()){
            Apttus__APTS_Agreement__c thisagreement = allagreements.get(agreeid);
            if(childMap.get(thisagreement.Apttus__Parent_Agreement__c)==NULL){
                childMap.put(thisagreement.Apttus__Parent_Agreement__c,new List<Apttus__APTS_Agreement__c>());
            }
            childMap.get(thisagreement.Apttus__Parent_Agreement__c).add(thisagreement);
        }
        for(id agrId : allagreements.keyset()){
            Integer levelCount = 1;
            Apttus__APTS_Agreement__c thisagreement = allagreements.get(agrId);
            if(thisagreement.Apttus__Parent_Agreement__c==NULL){
                boolean expand = false;
                AccountWrapper aw = new AccountWrapper(thisagreement,levelCount,expand,'white');
                aw.childagreements = getChildWrapperSet(thisagreement,levelCount);
                Agreements.add(aw);
            }
        }
        accountsJSON = JSON.serialize(Agreements);
        
        
        
        if(UserInfo.getUiThemeDisplayed() == 'Theme4d'){
            instanceURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/one/one.app#/sObject';
            backlink = System.URL.getSalesforceBaseUrl().toExternalForm() + '/one/one.app#/sObject/' +accid+'/view';
        }else{
            instanceURL = System.URL.getSalesforceBaseUrl().toExternalForm();
            backlink = System.URL.getSalesforceBaseUrl().toExternalForm()+ '/' +accid;
        }
    }
    Global static List<AccountWrapper> getchildwrappersetSt(Apttus__APTS_Agreement__c acc, Integer levelCount,Map<id,List<Apttus__APTS_Agreement__c>> childMap){
        List<AccountWrapper> childWrapper = new List<AccountWrapper>();
        List<Apttus__APTS_Agreement__c> directChildAccounts = new List<Apttus__APTS_Agreement__c>();
        String colorString;
        if(childMap.get(acc.id)!=NULL){
            directChildAccounts = childMap.get(acc.id);
            levelCount++;
            if(levelCount == 2)
            {
                colorString = '#F0F8FF';
            }
            else if(levelCount == 3)
            {
                colorString = '#F2F1FF';
            }
            else
            {
                colorString = 'rgb(' + (Math.floor(Math.random() * 56)+200) + ',' + (Math.floor(Math.random() * 56)+200) + ',' + (Math.floor(Math.random() * 56)+200) + ')';
            }
        }
        for(Apttus__APTS_Agreement__c accs: directChildAccounts){
            boolean collapse = false;
            AccountWrapper aw= new AccountWrapper(accs,levelCount,collapse,colorString);
            aw.childagreements = getchildwrappersetSt(accs,levelCount,childMap);
            childWrapper.add(aw);
        }
        return childWrapper;
    }
    Global List<AccountWrapper> getchildwrapperset(Apttus__APTS_Agreement__c acc, Integer levelCount){
        List<AccountWrapper> childWrapper = new List<AccountWrapper>();
        List<Apttus__APTS_Agreement__c> directChildAccounts = new List<Apttus__APTS_Agreement__c>();
        String colorString;
        if(childMap.get(acc.id)!=NULL){
            directChildAccounts = childMap.get(acc.id);
            levelCount++;
            if(levelCount == 2)
            {
                colorString = '#F0F8FF';
            }
            else if(levelCount == 3)
            {
                colorString = '#F2F1FF';
            }
            else
            {
                colorString = 'rgb(' + (Math.floor(Math.random() * 56)+200) + ',' + (Math.floor(Math.random() * 56)+200) + ',' + (Math.floor(Math.random() * 56)+200) + ')';
            }
        }
        for(Apttus__APTS_Agreement__c accs: directChildAccounts){
            boolean collapse = false;
            AccountWrapper aw= new AccountWrapper(accs,levelCount,collapse,colorString);
            aw.childagreements = getChildWrapperSet(accs,levelCount);
            childWrapper.add(aw);
        }
        return childWrapper;
    }
    
    Global class AccountWrapper{
        public boolean checkbox {get;set;}
        public Apttus__APTS_Agreement__c myagreement {get;set;}
        public string color {get;set;}
        public List<AccountWrapper> childagreements {get;set;}
        public Integer level;
        public AccountWrapper(Apttus__APTS_Agreement__c acc,Integer lev,boolean checkbox,String color){
            this.checkbox = checkbox;
            myagreement = acc;
            level = lev;
            this.color = color;
        }
    }
    Global class fieldWrapper{
        public string fieldAPIName{get;set;}
        public string fieldLabel{get;set;}
        public string getType{get;set;}
        public boolean isNameField{get;set;}
        public fieldWrapper(string fieldAPIName,string fieldLabel,string getType,boolean isNameField){
            if(getType == 'REFERENCE')
            {
                if(fieldAPIName == 'RecordTypeId'){
                   this.fieldAPIName = fieldAPIName.replace('RecordTypeId','RecordType'); 
                }
                else{
                    this.fieldAPIName = fieldAPIName.replace('_c','_r'); 
                }
            }
            else{
                this.fieldAPIName = fieldAPIName;
            }
            this.fieldLabel = fieldLabel;
            this.getType = getType;
            this.isNameField = isNameField;
        }
    }
    
    public static List<sObject> getListWSelectedFields(string objectName, string whereClaus, integer limitNumber,string extraRelationalFields,string orderByField1,string orderByField2,List<String> objectFields) {
        // Initialize setup variables
        String query = ' SELECT ';

        query+=extraRelationalFields;

        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields) {
           query += ' ' + s + ', ';
        }
    
        query = query.subString(0,query.Length()-2);
    
        // Add FROM statement
        query += ' FROM ' + objectName;
    
        // Add on a WHERE statement as needed
        if (String.isNotBlank(whereClaus)) {
          query += ' WHERE ' + whereClaus;
        }
        // Add on a Order by statement as needed
        if (String.isNotBlank(orderByField1)) {
          query += ' order by ' + orderByField1+','+orderByField2;
        }
        // Add on a LIMIT statement as needed
        if (limitNumber>0) {
          query += ' LIMIT ' + String.valueOf(limitNumber);
        }
        

        try {
          return database.query(query);
        } catch (QueryException qe) {
          
        return null;
        }
    }
    
    public List<sObject> getListWAllFields(string objectName, string whereClaus, integer limitNumber,string extraRelationalFields,string orderByField1,string orderByField2) {
        // Initialize setup variables
        //String objectName = 'Contact';  // modify as needed
        String query = ' SELECT ';
        Map<String, Schema.SObjectField> objectFields = getAllMetaDataFields(objectName);

        query+=extraRelationalFields;

        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
        }
    
        query = query.subString(0,query.Length()-2);
    
        // Add FROM statement
        query += ' FROM ' + objectName;
    
        // Add on a WHERE statement as needed
        if (String.isNotBlank(whereClaus)) {
          query += ' WHERE ' + whereClaus;
        }
        // Add on a Order by statement as needed
        if (String.isNotBlank(orderByField1)) {
          query += ' order by ' + orderByField1+','+orderByField2;
        }
        // Add on a LIMIT statement as needed
        if (limitNumber>0) {
          query += ' LIMIT ' + String.valueOf(limitNumber);
        }
        

        try {
          return database.query(query);
        } catch (QueryException qe) {
          System.debug(LoggingLevel.ERROR, '\n\n --- getListWAllFields --- '
            +'\n - objectName: ' + objectName
            +'\n - whereClaus: ' + whereClaus
            +'\n - query: ' + query
            +'\n - qe: ' + qe
        +'\n - qe: ' + qe.getMessage()
        +'\n - qe.getLineNumber: ' + qe.getLineNumber()
        +'\n - qe.getStackTraceString: ' + qe.getStackTraceString()
            +'\n'
          );
        return null;
        }
    }
    
    public Map<String, Schema.SObjectField> getAllMetaDataFields(string objName)
    {
        return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    }
    
   
}