global class APTSMD_LaunchQuoteInExcelXAEApp {

    global String configID {get;set;}
    global string appId {get; set;}
    private Apttus_Config2__ProductConfiguration__c config;
    global string objectTitle {get;set;}
    global string objectName {get;set;}
    private Apttus_Proposal__Proposal__c propObj;
    private Apttus__APTS_Agreement__c agmtObj;
    
         
    global  APTSMD_LaunchQuoteInExcelXAEApp(){
        configID = Apexpages.currentPage().getParameters().get('id');
        try{
            appId = ApexPages.currentPage().getParameters().get('appID');    
        }catch(Exception ex){
            appId = '';
        }
        config = [select Id, Apttus_Config2__BusinessObjectType__c,Apttus_Config2__BusinessObjectId__c from Apttus_Config2__ProductConfiguration__c where Id = :configID];
        if(config.Apttus_Config2__BusinessObjectType__c == 'Proposal'){
            objectTitle = 'Quote/Proposal';
            propObj = [select id, Name from Apttus_Proposal__Proposal__c where Id = : config.Apttus_Config2__BusinessObjectId__c limit 1];
            objectName = propObj.Name;
        } else if(config.Apttus_Config2__BusinessObjectType__c == 'Agreement'){
            objectTitle = 'Agreement';
            agmtObj = [select id, Name from Apttus__APTS_Agreement__c where Id = : config.Apttus_Config2__BusinessObjectId__c limit 1];
            objectName = agmtObj.Name;
        }
    }

}