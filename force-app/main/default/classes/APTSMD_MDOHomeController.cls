public class APTSMD_MDOHomeController {
    
    public List<APTSMD_MDO_Postspin_Steps__c> listMDOPostspinSteps {get;set;}
    public String baseURL {get;set;}
    public APTSMD_MDOHomeController(){
        
        listMDOPostspinSteps = new List<APTSMD_MDO_Postspin_Steps__c>();
        listMDOPostspinSteps = [select id,name,APTSMD_Active__c,APTSMD_Description__c,APTSMD_Sequence__c,APTSMD_URL__c,APTSMD_Required__c 
                                from APTSMD_MDO_Postspin_Steps__c where APTSMD_Active__c=true order by APTSMD_Sequence__c];
                                
        baseURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/';
    }
    @AuraEnabled
    public static string getMDOVersion() {
        
        List<APTSMD_Apttus_PreSales_Config_Settings2__c> presalesConfigSettings;
        String mdoVersion;
        presalesConfigSettings = new List<APTSMD_Apttus_PreSales_Config_Settings2__c>();
        presalesConfigSettings.add(APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults());
        mdoVersion = presalesConfigSettings[0].APTSMD_MDO_Version__c;
        return mdoVersion;
    }
    @AuraEnabled
    public static string getOrgExpirationDate() {
        String orgExpirationDate;
        Organization organ = [Select id, TrialExpirationDate from organization];
        orgExpirationDate = '';
        if(organ.TrialExpirationDate != null){
            orgExpirationDate += organ.TrialExpirationDate.month() + '/' + organ.TrialExpirationDate.day() + '/' + organ.TrialExpirationDate.year();
        }
        return orgExpirationDate;
    }
    @AuraEnabled
    public static string getApttusLicenseExpirationDate() {
        
        String apttusLicenseExpirationDate;
        
        String PACKAGE_NAMESPACE_PREFIX = 'Apttus';
        //PackageLicense p1 = new PackageLicense();
        PackageLicense pl = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, 
                                 ExpirationDate, Status FROM PackageLicense WHERE 
                                 NamespacePrefix = :PACKAGE_NAMESPACE_PREFIX];
        
        apttusLicenseExpirationDate = '';
        if(pl.ExpirationDate != null){
            apttusLicenseExpirationDate += pl.ExpirationDate.month() + '/' + pl.ExpirationDate.day() + '/' + pl.ExpirationDate.year();
        }
        return apttusLicenseExpirationDate;
    }
        
    public List<APTSMD_MDO_Postspin_Steps__c> getMDOPostSpinTasks(){
        
        
        
        return listMDOPostspinSteps;
    }
    
        
        
        
        
        

}