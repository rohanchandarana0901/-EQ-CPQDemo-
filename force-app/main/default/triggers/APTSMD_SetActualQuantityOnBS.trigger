//created on: 29 Jan 2022 Jigar Naik
trigger APTSMD_SetActualQuantityOnBS on Apttus_Billing__UsageSchedule__c(after update){
    
    /****Purpose : This trigger will populate Actual Quantity on Billing Schedule by reading Usgae Schedules 
            for Usage based asset line items.So that Actual Quantity will be considered in Invoicing and it 
            will be displayed in Invoice template.****/
    
    Set<Id> billingScheduleIds = new Set<Id>();
    Map<Id,Decimal> billingSchIdvsActualQtyMap = new Map<Id,Decimal>();
    List<AggregateResult> usageSchedules;
    List<Apttus_Billing__BillingSchedule__c> billingSchedules = new List<Apttus_Billing__BillingSchedule__c>();
    
    for(Apttus_Billing__UsageSchedule__c usageSchedule : Trigger.New){
        if(usageSchedule.Apttus_Billing__ActualQuantity__c != 0 && usageSchedule.Apttus_Billing__ActualQuantity__c != null){
            billingScheduleIds.add(usageSchedule.Apttus_Billing__BillingScheduleId__c);
        }
    }
    
    if(!billingScheduleIds.isEmpty()){
        usageSchedules = [Select Apttus_Billing__BillingScheduleId__c, SUM(Apttus_Billing__ActualQuantity__c) totalActualQuantity
                            From Apttus_Billing__UsageSchedule__c
                            Where Apttus_Billing__BillingScheduleId__c in :billingScheduleIds
                            Group By Apttus_Billing__BillingScheduleId__c];
        if(!usageSchedules.isEmpty()){
            for(AggregateResult usageSchedule : usageSchedules){
                billingSchIdvsActualQtyMap.put((Id)usageSchedule.get('Apttus_Billing__BillingScheduleId__c'), (Decimal)usageSchedule.get('totalActualQuantity'));
            }
        }
    }
    
    for(Id billingScheduleId : billingScheduleIds){
        if(billingSchIdvsActualQtyMap.containsKey(billingScheduleId)){
            billingSchedules.add(new Apttus_Billing__BillingSchedule__c(Id = billingScheduleId, Apttus_Billing__Quantity__c = billingSchIdvsActualQtyMap.get(billingScheduleId)));
        }
    }
    
    if(!billingSchedules.isEmpty()){
        update billingSchedules;
    }
}