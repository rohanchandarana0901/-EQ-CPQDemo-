trigger APTSMD_AddContractNumberToAccount on Apttus_Config2__PriceList__c (after insert) {
    if(Trigger.New.size() > 1){
        system.debug('###Contract pricing is supported for only one price list at a time.');
        return;
    }
    
    Apttus_Config2__PriceList__c priceList = Trigger.new[0];
    if( priceList.Apttus_Config2__Type__c == 'Contract'){
        Account account = [Select Id, Name, APTSMD_Contract_Numbers__c
                      from Account Where Id = :priceList.Apttus_Config2__AccountId__c];   
        if (account.APTSMD_Contract_Numbers__c != null && !account.APTSMD_Contract_Numbers__c.contains(priceList.Apttus_Config2__ContractNumber__c)){  
            account.APTSMD_Contract_Numbers__c += ',' + priceList.Apttus_Config2__ContractNumber__c;
        }
        else{
            account.APTSMD_Contract_Numbers__c = priceList.Apttus_Config2__ContractNumber__c;            
        }
        
        system.debug('###Contract Number(s) for account ' + account.Name + ' are ' + account.APTSMD_Contract_Numbers__c);
        update account;
    }
}