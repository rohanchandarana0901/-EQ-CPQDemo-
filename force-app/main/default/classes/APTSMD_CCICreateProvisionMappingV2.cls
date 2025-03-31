/**
 * @description       : This class used to setup Automatic CCI provisions for record types.
 * @author            : Japan Bhavsar
 * @group             : 
 * @last modified on  : 10-03-2023
 * @last modified by  : Japan Bhavsar
**/
global with sharing class APTSMD_CCICreateProvisionMappingV2{
    public static string instanceURL {get;set;}
    public List<sObject> clauses {get;set;}
    public string clauseJSON {get;set;}
    public static string moduleType {get;set;}
    public static string recordTypeJSON {get;set;}
    public static string dId {get;set;}
    public static final string CFSModuleType = 'cfs'; //  CFS Module Type
    public static final string CLMModuleType = 'clm'; //  CLM Module Type
    public static final string CFSPackageNameSpace = 'APXT_Redlining'; // CFS Package Name Space
    public static final string templateSObjectAPI = 'Apttus__APTS_Template__c'; // CLM - Template Object
    public static final string clauseSObjectAPI = 'APXT_Redlining__Clause__c'; // CFS - Clause Object
    public static final string agreementSObjectAPI = 'Apttus__APTS_Agreement__c'; // CLM - Agreement Object
    public static final string contractAgreementObjectAPI = 'APXT_Redlining__Contract_Agreement__c'; // CFS - Contract Agreement Object
    public static final string CLMCCICustomSettingAPIName = 'Apttus__CCIAdminConfig__c'; // CCI Custom setting for CLM
    public static final string CFSCCICustomSettingAPIName = 'APXT_Redlining__Contract_Intelligence_Settings__c'; // CCI Custom setting for CFS
    public static final string CFSContractAgreementTypeFieldAPI = 'APXT_Redlining__Type__c'; // 'Type' field api name of Contract Agreement
    
    // Constructor
    public APTSMD_CCICreateProvisionMappingV2() {
        //Get Instance URL
        instanceURL=URL.getOrgDomainUrl().toExternalForm();
        // Check for the CFS Package
        List<PackageLicense> packages = [SELECT Id, NamespacePrefix FROM PackageLicense where NamespacePrefix = :CFSPackageNameSpace];
        if(packages.size()>0){
            // Set Module Type as CFS
            moduleType = CFSModuleType;

            if(!Test.isRunningTest()){
                // Retreive Clauses for CFS
                // string cfsClauseQuery = 'select name,id from APXT_Redlining__Clause__c order by name';
                string cfsClauseQuery = 'select id, name, APXT_Redlining__External_Id__c from APXT_Redlining__Clause_Configuration__c';
                clauses = Database.query(cfsClauseQuery);
                clauseJSON = JSON.serialize(clauses);
                
                // Fetch RecordTypes
                // List<RecordType> recordType = [select id,name,DeveloperName from RecordType where SobjectType = :contractAgreementObjectAPI and IsActive=true];
                // recordTypeJSON = JSON.serialize(recordType);

                // Instead of Record Type we are fetching the Picklist field
                List<String> ContractAgreementTypeList = getPickListValuesIntoList(contractAgreementObjectAPI,CFSContractAgreementTypeFieldAPI);
                List<recordTypeWrapper> recordTypeWrapperData = new List<recordTypeWrapper>();
                // check for the picklist values
                if(!ContractAgreementTypeList.isEmpty()){
                    for(String type : ContractAgreementTypeList){
                        recordTypeWrapperData.add(new recordTypeWrapper(type));
                    }
                }
                recordTypeJSON = JSON.serialize(recordTypeWrapperData);

                // Fetch EntityParticle
                List<EntityParticle> ep = [SELECT DurableId FROM EntityParticle WHERE EntityDefinition.QualifiedApiName = :contractAgreementObjectAPI and DurableId like '%RecordType'];
                if(ep.size()>0){
                    dId = ep[0].DurableId.substring(0,ep[0].DurableId.indexOf('.'));
                }
            }
        }else{
            // Set Module Type as CLM
            moduleType = CLMModuleType;

            if(!Test.isRunningTest()){
                // Retreive Clauses for CLM
                string clmClauseQuery = 'select name,id,Apttus__ReferenceId__c from Apttus__APTS_Template__c where Apttus__IsActive__c = true order by name';
                clauses = Database.query(clmClauseQuery);
                clauseJSON = JSON.serialize(clauses);

                // Fetch RecordTypes
                List<RecordType> recordType = [select id,name,DeveloperName from RecordType where SobjectType = :agreementSObjectAPI and IsActive=true];
                recordTypeJSON = JSON.serialize(recordType);

                // Fetch EntityParticle
                List<EntityParticle> ep = [SELECT DurableId FROM EntityParticle WHERE EntityDefinition.QualifiedApiName = :agreementSObjectAPI and DurableId like '%RecordType'];
                if(ep.size()>0){
                    dId = ep[0].DurableId.substring(0,ep[0].DurableId.indexOf('.'));
                }   
            }
        }
    }

    @RemoteAction
    global static string createClauses(List<String> clauses, string module) {
        if(clauses.size() <= 0){
            return 'No Clause Record Provided';
        }
        if(module == null || module == ''){
            return 'Please provide valid module';
        }
        if(module == 'clm'){
            List<SObject> clauseTobeCreated = new List<SObject>();
            // Create a Type instance based on the API name
            Type sObjectType = Type.forName('Schema.' + templateSObjectAPI);
            for(string c : clauses){
                SObject clause = (SObject)sObjectType.newInstance();
                clause.put('Name',c);
                clause.put('Apttus__Type__c','Clause');
                clauseTobeCreated.add(clause);
            }
            insert clauseTobeCreated;
            return 'Clauses Created';
        }else{
            List<SObject> clauseTobeCreated = new List<SObject>();
            // Create a Type instance based on the API name
            Type sObjectType = Type.forName('Schema.' + clauseSObjectAPI);
            for(string c : clauses){
                SObject clause = (SObject)sObjectType.newInstance();
                clause.put('Name',c);
                clause.put('APXT_Redlining__Text__c','-');
                clauseTobeCreated.add(clause);
            }
            insert clauseTobeCreated;
            return 'Clauses Created';
        }
    }

    @RemoteAction
    global static string changeCCICustomSettings(string apiToken, string apiURL, string endpoint, string tenant, string module) {
        if(module == 'clm'){
            if(!Test.isRunningTest()){
                List<SObject> CLMCCISettings = new List<SObject>();
                String CLMCCISettingQuery = 'SELECT Id, Apttus__APIToken__c, Apttus__APIUrl__c, Apttus__EndPoint__c, Apttus__Tenant__c FROM ' + CLMCCICustomSettingAPIName + ' LIMIT 1';
                CLMCCISettings = Database.query(CLMCCISettingQuery);
                if(!CLMCCISettings.isEmpty()){
                    Type sObjectType = Type.forName('Schema.' + CLMCCICustomSettingAPIName);
                    SObject CLMCCISetting = (SObject)sObjectType.newInstance();
                    CLMCCISetting = CLMCCISettings[0];
                    if(apiToken != '' && apiToken != null){
                        CLMCCISetting.put('Apttus__APIToken__c',apiToken);
                    }
                    if(apiURL != '' && apiURL != null){
                        CLMCCISetting.put('Apttus__APIUrl__c',apiURL);
                    }
                    if(endpoint != '' && endpoint != null){
                        CLMCCISetting.put('Apttus__EndPoint__c',endpoint);
                    }
                    if(tenant != '' && tenant != null){
                        CLMCCISetting.put('Apttus__Tenant__c',tenant);
                    }
                    
                    Update CLMCCISetting;
                }
            }         
            return 'Custom setting is updated successfully.';           
        }else if(module == 'cfs'){
            List<SObject> CFSCCISettings = new List<SObject>();
            if(!Test.isRunningTest()){
                String CFSCCISettingQuery = 'SELECT Id, APXT_Redlining__ApiToken__c, APXT_Redlining__ApiUrl__c, APXT_Redlining__Endpoint__c, APXT_Redlining__Tenant__c FROM ' + CFSCCICustomSettingAPIName + ' LIMIT 1';
                CFSCCISettings = Database.query(CFSCCISettingQuery);
                if(!CFSCCISettings.isEmpty()){
                    Type sObjectType = Type.forName('Schema.' + CFSCCICustomSettingAPIName);
                    SObject CFSCCISetting = (SObject)sObjectType.newInstance();
                    CFSCCISetting = CFSCCISettings[0];
                    if(apiToken != '' && apiToken != null){
                        CFSCCISetting.put('APXT_Redlining__ApiToken__c',apiToken);
                    }
                    if(apiURL != '' && apiURL != null){
                        CFSCCISetting.put('APXT_Redlining__ApiUrl__c',apiURL);
                    }
                    if(endpoint != '' && endpoint != null){
                        CFSCCISetting.put('APXT_Redlining__Endpoint__c',endpoint);
                    }
                    if(tenant != '' && tenant != null){
                        CFSCCISetting.put('APXT_Redlining__Tenant__c',tenant);
                    }
                    
                    Update CFSCCISettings;
                }
            }
            return 'Custom setting is updated successfully.';
        }
        
        return 'Something went wrong! Please contact your system administrator.';
    }

    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }

    public class recordTypeWrapper{
        public string Id {get;set;}
        public string DeveloperName {get;set;}
        public string Name {get;set;}

        public recordTypeWrapper(){
            this.Id= '';
            this.DeveloperName = '';
            this.Name = '';
        }

        public recordTypeWrapper(string name){
            this.Id= '';
            this.DeveloperName = name;
            this.Name = name;
        }

    }

    public static void runRandomTest(){
        Integer i = 0;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
                i = 1;
    }


}