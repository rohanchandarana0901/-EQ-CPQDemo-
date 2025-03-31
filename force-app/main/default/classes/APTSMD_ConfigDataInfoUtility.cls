// Added By Japan Bhavsar
global with sharing class APTSMD_ConfigDataInfoUtility {

    public static string  getCurrAndDateFormat(boolean isCurrNeeded,string currencyISO){
        
        // For now currency and date format is hardcoded.
        if(isCurrNeeded){
            return '$';   
        }else{
            return 'MM/dd/yyyy';   
        }
    }
}