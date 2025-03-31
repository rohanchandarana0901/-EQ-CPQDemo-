/**
 * Company      : Apttus Inc.
 * Description  : In case of Ramp lines, we have to distribute total amount of all ramps equally between all corresponding Agreement Fee records.
 *                Using this trigger, we are getting all Asset Lines and checking that is any of the asset lines is having ramps,
 *                then we are totaling the net price of all ramp lines and calculating average amount for each ramp 
 *                which is set in Flat Fee field on Agreement Fee object.
 * History      :
 * [22.Aug.2019]: Parth Doshi Created Trigger 
 */
trigger APTSMD_SetFlatFee on Apttus_Revenue2__Agreement_Fee__c (before insert) {

    List<Apttus_Revenue2__Agreement_Fee__c> tempAgmtFeeList = new List<Apttus_Revenue2__Agreement_Fee__c>();
    List<Apttus_Config2__AssetLineItem__c> tempASLList = new List<Apttus_Config2__AssetLineItem__c>();
    Set<Id> tempALIIds = new Set<Id>();
    for(Apttus_Revenue2__Agreement_Fee__c agrFee : Trigger.new){
        tempALIIds.add(agrFee.Apttus_RVConfig__AssetLineItemId__c);
    }
    System.debug('tempALIIds ->' + tempALIIds);
    Map<Id,Decimal> ASLIdvsAmount = new Map<Id, Decimal>();
    // Fetch Asset Line Items
    tempASLList = [select id, name, Apttus_Config2__ItemSequence__c, Apttus_Config2__LineNumber__c, Apttus_Config2__BundleAssetId__c,
                    Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__NetPrice__c
                    from Apttus_Config2__AssetLineItem__c where Id in :tempALIIds];
                
    // Loop Through Asset Line Item
    for(Apttus_Config2__AssetLineItem__c aslOuter : tempASLList){
        if(aslOuter.Apttus_Config2__IsPrimaryLine__c && aslOuter.Apttus_Config2__IsPrimaryRampLine__c){
            System.debug('aslOuter ->' + aslOuter);
            Decimal totalAmount = 0;
            Integer rampLineNumber = 0;
            // Check for Ramp Lines
            for(Apttus_Config2__AssetLineItem__c aslInner : tempASLList){
                if(aslOuter.Apttus_Config2__LineNumber__c == aslInner.Apttus_Config2__LineNumber__c){
                    totalAmount += aslInner.Apttus_Config2__NetPrice__c;
                    rampLineNumber += 1;
                }
            }
            // Calculate Avg Amount
            Decimal avgAmount = 0; 
            if(rampLineNumber != 0){
                avgAmount = (totalAmount/rampLineNumber);    
            }
            System.debug('totalAmount -> '+ totalAmount);
            System.debug('rampLineNumber -> '+ rampLineNumber);
            System.debug('avgAmount -> '+ avgAmount);
            for(Apttus_Config2__AssetLineItem__c aslInner : tempASLList){
                if(aslOuter.Apttus_Config2__LineNumber__c == aslInner.Apttus_Config2__LineNumber__c){
                   ASLIdvsAmount.put(aslInner.Id,avgAmount);
                }
            }
        }
    }
    System.debug('ASLIdvsAmount -> '+ ASLIdvsAmount);
    // Now update flat price
    for(Apttus_Revenue2__Agreement_Fee__c agrFee : Trigger.new){
        if(ASLIdvsAmount.containsKey(agrFee.Apttus_RVConfig__AssetLineItemId__c)){
            agrFee.Apttus_Revenue2__Flat_Fee__c = ASLIdvsAmount.get(agrFee.Apttus_RVConfig__AssetLineItemId__c);
            agrFee.Apttus_Revenue2__TransactionPrice__c = ASLIdvsAmount.get(agrFee.Apttus_RVConfig__AssetLineItemId__c);
            agrFee.Apttus_Revenue2__Deferred_Balance_Amount__c = ASLIdvsAmount.get(agrFee.Apttus_RVConfig__AssetLineItemId__c);
            agrFee.Apttus_Revenue2__Forecast_Deferred_Balance_Amount__c = ASLIdvsAmount.get(agrFee.Apttus_RVConfig__AssetLineItemId__c);
            System.debug('Flat Price -> ' + agrFee.Apttus_Revenue2__Flat_Fee__c);
        }
    }
}