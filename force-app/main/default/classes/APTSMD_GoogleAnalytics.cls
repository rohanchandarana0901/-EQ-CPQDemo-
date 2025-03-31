public class APTSMD_GoogleAnalytics {

    public boolean isEnableGA {get; set;}
    private APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting;
    
    public APTSMD_GoogleAnalytics() {
        
        presalesSetting = [select id, name,APTSMD_Show_Logo_In_Custom_Pages__c, APTSMD_Enable_Google_Analytics__c
                    from APTSMD_Apttus_PreSales_Config_Settings2__c where Name = 'System Properties' limit 1];
                    
        if(presalesSetting != null){  
            this.isEnableGA = presalesSetting.APTSMD_Enable_Google_Analytics__c;
        }else{
            this.isEnableGA = false;
        }
    }

}