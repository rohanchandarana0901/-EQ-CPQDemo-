public class APTSMD_SE_LINK_Controller {
    
    @auraenabled
    public static ConfigProperties getConfigSettingsData(){   
        return new ConfigProperties();
    }

	@auraenabled
    public static apiResponse toggleGoogleDoc(){
        try{
            Apttus__ComplySystemProperties__c complySystemProperties = Apttus__ComplySystemProperties__c.getInstance('System Properties');
            complySystemProperties.Apttus__EnableGoogleDrive__c = !complySystemProperties.Apttus__EnableGoogleDrive__c;
            complySystemProperties.Apttus__MergeWebserviceEndpoint__c = (complySystemProperties.Apttus__EnableGoogleDrive__c ? 'https://coreapps-rlspreview.congacloud.com/api/integrate/v1/execute' : 'https://merge.congacloud.com/cgi-bin/MergeServer/Bin/mmcgi.exe');
            complySystemProperties.Apttus__EnableDocumentVersioning__c = (complySystemProperties.Apttus__EnableGoogleDrive__c ? true : false);
            Update complySystemProperties;
            return new apiResponse(true, (complySystemProperties.Apttus__EnableGoogleDrive__c ? 'Conga for Google Docs' : 'Conga CLM') + ' settings enabled successfully!', complySystemProperties);        
        }catch(Exception ex){
            return new apiResponse(false, 'Exception: ' + ex.getMessage() + '@ Line#: ' + ex.getLineNumber(), null);
        }
    }
    
    // Helper Classes
    public class ConfigProperties{
        @auraenabled
        public Apttus__ComplySystemProperties__c complySystemProperties {get;set;}
        @auraenabled
        public APTSMD_Apttus_PreSales_Config_Settings2__c presaleConfigSetting {get;set;}
        // Defining the constructor to set the values for the properties
        public ConfigProperties(){
            this.complySystemProperties = Apttus__ComplySystemProperties__c.getInstance('System Properties');
            this.presaleConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance();            
        }
    }
    
    public class apiResponse {
        @auraenabled
        public boolean isSuccess {get;set;}
        @auraenabled
        public string message {get;set;}
        @auraenabled
        public object data {get;set;}
        
        public apiResponse(boolean isSuccess, string message, object data){
            this.isSuccess = isSuccess;
            this.message = message;
            this.data = data;
        }
    }
    

}