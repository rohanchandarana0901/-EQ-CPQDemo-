trigger APTSMD_SetActualQuantity on Apttus_Billing__BillingSchedule__c(before update){
    
    /****Purpose : This trigger will populate Actual Quantity on Billing Schedule by reading Usgae Schedules 
            for Usage based asset line items.So that Actual Quantity will be considered in Invoicing and it 
            will be displayed in Invoice template.****/
    
    Set<Id> billingScheduleIds = new Set<Id>();
    Map<Id,Decimal> billingSchIdvsActualQtyMap = new Map<Id,Decimal>();
    List<Apttus_Billing__UsageSchedule__c> usageSchedules;
    
    for(Apttus_Billing__BillingSchedule__c billingSchedule : trigger.New){
        if(billingSchedule.Apttus_Billing__FeeAmount__c != 0 && billingSchedule.Apttus_Billing__FeeAmount__c != null){
            billingScheduleIds.add(billingSchedule.Id);
        }
    }
    if(!billingScheduleIds.isEmpty()){
        usageSchedules = [Select Id,Apttus_Billing__BillingScheduleId__c,Apttus_Billing__Type__c,Apttus_Billing__ActualQuantity__c from Apttus_Billing__UsageSchedule__c where Apttus_Billing__BillingScheduleId__c in :billingScheduleIds]; 
        if(!usageSchedules.isEmpty()){
            for(Apttus_Billing__UsageSchedule__c usageSchedule : usageSchedules){
                billingSchIdvsActualQtyMap.put(usageSchedule.Apttus_Billing__BillingScheduleId__c,usageSchedule.Apttus_Billing__ActualQuantity__c);
            }
        }
    }
    for(Apttus_Billing__BillingSchedule__c billingSchedule : trigger.New){
        if(billingSchIdvsActualQtyMap.containsKey(billingSchedule.id))
            billingSchedule.Apttus_Billing__Quantity__c = billingSchIdvsActualQtyMap.get(billingSchedule.id);    
    }
    
}