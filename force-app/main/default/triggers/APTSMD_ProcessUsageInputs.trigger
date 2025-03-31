trigger APTSMD_ProcessUsageInputs on Apttus_Billing__UsageInput__c (after insert) {
    
    /****Purpose : This trigger is used to process usage inputs automatically when usage input records are inserted 
                   from XAE app - Usage Input Management. ****/
    
    Set<Id> usageInputIds = new Set<Id>();
    for(Apttus_Billing__UsageInput__c usageInput : Trigger.New){
        if(usageInput.Apttus_Billing__Status__c == 'Loaded' && usageInput.APTSMD_XAE_Usage_Input__c){
            usageInputIds.add(usageInput.Id);
        }
    }
    if(usageInputIds.size() > 0){
        Apttus_Billing.BillingService.processPendingUsageInput(usageInputIds);
    }
}