global with sharing class APTSMD_UpdateCurrencyCodeCtrl {
    
    @RemoteAction
    global static Boolean setCurrency(String currencyCode) {
        
        try{
            List<User> userList = [Select Id, CurrencyIsoCode, DefaultCurrencyIsoCode from User Where IsActive = true and Email like '%conga.com%'];
            for(User user : userList){
                user.CurrencyIsoCode = currencyCode;
                user.DefaultCurrencyIsoCode = currencyCode;
            }
            update userList;
            
            List<Apttus_Config2__PriceList__c> plList = [Select Id, CurrencyIsoCode from Apttus_Config2__PriceList__c Where Apttus_Config2__Active__c = true];
            for(Apttus_Config2__PriceList__c pl : plList){
                pl.CurrencyIsoCode = currencyCode;
            }
            update plList;
            
            List<Apttus_Config2__PriceListItem__c> pliList = [Select Id, CurrencyIsoCode, Apttus_Config2__ListPrice__c, Apttus_Config2__Cost__c from Apttus_Config2__PriceListItem__c Where Apttus_Config2__Active__c = true];
            for(Apttus_Config2__PriceListItem__c pli : pliList){
                pli.CurrencyIsoCode = currencyCode;
                pli.Apttus_Config2__ListPrice__c = pli.Apttus_Config2__ListPrice__c;
                pli.Apttus_Config2__Cost__c = pli.Apttus_Config2__Cost__c;
            }
            update pliList;
            
            return true;
        }
        catch(Exception ex){
            System.debug('Error Occurred while setting Currency='+ex.getmessage());
            return false;
        }
    }

}