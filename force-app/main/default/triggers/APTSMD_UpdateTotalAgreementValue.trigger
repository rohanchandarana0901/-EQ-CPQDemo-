trigger APTSMD_UpdateTotalAgreementValue on Apttus_Config2__ProductConfiguration__c (after update) {
    if(Trigger.New.size() > 1){
        return;
    }
    
    if(Trigger.New[0].Apttus_Config2__BusinessObjectType__c != 'Agreement'){
        return;
    }
    
    if(Trigger.Old[0].Apttus_Config2__Status__c != Trigger.New[0].Apttus_Config2__Status__c && Trigger.New[0].Apttus_Config2__Status__c == 'Finalized'
        && Trigger.New[0].APTSMD_Grand_Total__c > 0){
        update new Apttus__APTS_Agreement__c(Id = Trigger.New[0].Apttus_Config2__BusinessObjectId__c, Apttus__Total_Contract_Value__c = Trigger.New[0].APTSMD_Grand_Total__c);
    }
}