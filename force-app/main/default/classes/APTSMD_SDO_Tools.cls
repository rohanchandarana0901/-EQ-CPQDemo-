public with sharing class APTSMD_SDO_Tools {
    
    public List<wCategory> category_list {get;set;}
    public List<APTSMD_Wizard__c> wList {get;set;}
    public APTSMD_Wizard__c toolsWizard {get;set;}
    public Map<String,List<APTSMD_Wizard_Step_Tool__c>> wizardStepId_ToolsList_Map {get;set;}

    public list<APTSMD_SDO_Tool__c> tools {get;set;}
    public list<APTSMD_SDO_Tool__c> toolsTiles {get;set;}

    public list<APTSMD_SDO_Tool__c> salesTools {get;set;}
    public list<APTSMD_SDO_Tool__c> serviceTools {get;set;}
    public list<APTSMD_SDO_Tool__c> marketingTools {get;set;}
    public list<APTSMD_SDO_Tool__c> platformTools {get;set;}
    public list<APTSMD_SDO_Tool__c> analyticsTools {get;set;}
    public list<APTSMD_SDO_Tool__c> communityTools {get;set;}
    public list<APTSMD_SDO_Tool__c> otherTools {get;set;}

    public list<APTSMD_SDO_Tool__c> favorites {get;set;}
    public Map<String,String> pageNameMap {get;set;}

    public List<APTSMD_SDO_News__c> news {Get;set;}

    public List<APTSMD_Apttus_PreSales_Config_Settings2__c> presalesConfigSettings {get;set;}
    public String mdoVersion {get;set;}
    
    public String orgExpirationDate {get;set;}
    public String salesforceLicenseExpirationDate {get;set;}
    public String apttusLicenseExpirationDate {get;set;}
    
    //Code By Mayur for Resources
    public List<APTSMD_MDOHomeResources__c> listReleaseNotes{get;set;}
    public List<APTSMD_MDOHomeResources__c> listCPQ{get;set;}
    public List<APTSMD_MDOHomeResources__c> listCLM{get;set;}
    public List<APTSMD_MDOHomeResources__c> listBillingRevRec{get;set;}
    public List<APTSMD_MDOHomeResources__c> listECommercePortal{get;set;}
    public List<APTSMD_MDOHomeResources__c> listICPQ{get;set;}
    public Boolean CPQSection {get; set;}
    public Boolean CLMSection {get; set;}
    public Boolean billingSection {get; set;}
    public Boolean eCommerceSection {get; set;}
    public Boolean iCPQSection {get; set;}
    
    
    public APTSMD_SDO_Tools() {
      //Get MDO Version
        presalesConfigSettings = new List<APTSMD_Apttus_PreSales_Config_Settings2__c>();
        presalesConfigSettings.add(APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults());
        mdoVersion = presalesConfigSettings[0].APTSMD_MDO_Version__c;
        
        
        Organization organ = [Select id, TrialExpirationDate from organization];
        orgExpirationDate = '';
        if(organ.TrialExpirationDate != null){
            orgExpirationDate += organ.TrialExpirationDate.month() + '/' + organ.TrialExpirationDate.day() + '/' + organ.TrialExpirationDate.year();
        }
        
        
        String PACKAGE_NAMESPACE_PREFIX = 'Apttus';
        //PackageLicense p1 = new PackageLicense();
        PackageLicense pl = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, 
                                 ExpirationDate, Status FROM PackageLicense WHERE 
                                 NamespacePrefix = :PACKAGE_NAMESPACE_PREFIX];
        
        apttusLicenseExpirationDate = '';
        if(pl.ExpirationDate != null){
            apttusLicenseExpirationDate += pl.ExpirationDate.month() + '/' + pl.ExpirationDate.day() + '/' + pl.ExpirationDate.year();
        }
        
        
        //get instance url
        String instance;
        List<String> parts = System.URL.getSalesforceBaseUrl().getHost().split('\\.');
        if (parts.size() == 3) instance = parts[0];
        else if (parts.size() == 5) instance = parts[1];
        else if (parts.size() == 4) instance = parts[0]+ '.' +parts[1];
        else instance = null;
        
        
        String orgId = '';
        orgId += organ.id;
        
         //modify by Jeetu Agrawal 30/10/2018
        List<String> instanceTemp = instance.split('--c');
        if(instanceTemp.size()>0)
        instance = instanceTemp[0];
        
        String targetURL = 'https://'+ instance + '.my.salesforce.com/' + orgId;
        String pageText = new PageReference(targetURL).getContent().toString();
        integer index = pageText.indexOf('<td class=" dataCell  DateElement">');
        index = index + 35;
        salesforceLicenseExpirationDate = pageText.substring(index, index+10);
        System.debug(salesforceLicenseExpirationDate);
        
        //date string can have 9-10 digits so if it has 9 digits the 10th digit must be not numeric
        String lastDigit = salesforceLicenseExpirationDate.substring(salesforceLicenseExpirationDate.length()-2);
        Pattern isnumbers = Pattern.Compile('^[0-9]+$');
        Matcher numMatch = isnumbers.matcher(lastDigit);
        if(numMatch.Matches()){
            //has only numbers
        }else{
            salesforceLicenseExpirationDate = pageText.substring(index, index+9);
        }
        
        Initialize();
    }
    
    public APTSMD_SDO_Tools(APTSMD_SDOToolsHomepage sdoToolsHomepage) {
        Initialize();
    }

    public void Initialize() { //ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,
        news = [SELECT Name,APTSMD_News_Content__c,APTSMD_News_Item_Image__c,OwnerId,APTSMD_Published_Date__c,APTSMD_Showcase_Link__c,SystemModstamp FROM APTSMD_SDO_News__c ORDER BY APTSMD_Published_Date__c DESC NULLS FIRST];
        

        //initialize the wizard
        toolsWizard = [select 
                        (select id,APTSMD_Page_Content_Name__c, APTSMD_step_order__c,name,APTSMD_description__c from Wizard_Steps__r order by APTSMD_step_order__c asc)
                        id from APTSMD_Wizard__c limit 1];
        wizardStepId_ToolsList_Map = new Map<String,List<APTSMD_Wizard_Step_Tool__c>>();
        for(APTSMD_Wizard_step__c ws : toolsWizard.Wizard_Steps__r) {
           List<APTSMD_Wizard_Step_Tool__c>  wstList = [select id,name, APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_SDO_Tool__c,APTSMD_sdo_tool__r.APTSMD_Advanced_Information__c, APTSMD_sdo_tool__r.name, APTSMD_sdo_tool__r.APTSMD_description__c, APTSMD_sdo_tool__r.APTSMD_instructions__c, APTSMD_tool_order__c, APTSMD_Wizard_step__c from APTSMD_Wizard_Step_Tool__c where APTSMD_Wizard_step__c =: ws.id order by APTSMD_tool_order__c];
           wizardStepId_ToolsList_Map.put(ws.id,wstList);
           pageNameMap = new Map<String,String>();
           if(ws.APTSMD_Page_Content_Name__c != null) {
              pageNameMap.put(ws.APTSMD_Page_Content_Name__c,ws.APTSMD_Page_Content_Name__c);
           }
        }
        tools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              Order by name asc]; 
        toolsTiles = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              Order by APTSMD_product_Cloud__c];
        salesTools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              AND APTSMD_product_Cloud__c = 'Sales Cloud'
                              Order by name asc];
        serviceTools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              AND APTSMD_product_Cloud__c = 'Service Cloud'
                              Order by name asc];
        marketingTools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              AND APTSMD_product_Cloud__c = 'Marketing Cloud'
                              Order by name asc];
        platformTools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              AND APTSMD_product_Cloud__c = 'Platform'
                              Order by name asc];                                                                                          
        analyticsTools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              AND APTSMD_product_Cloud__c = 'Analytics Cloud'
                              Order by name asc];
        communityTools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              AND APTSMD_product_Cloud__c = 'Community Cloud'
                              Order by name asc];
        otherTools = [Select Id, Name,APTSMD_active__c,APTSMD_product_Cloud__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_instructions__c,APTSMD_Advanced_Information__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true
                              AND APTSMD_product_Cloud__c = 'Other'
                              Order by name asc];
        favorites = [Select Id, Name,APTSMD_active__c,APTSMD_favorite__c, APTSMD_url__c,APTSMD_fa_icon_name__c,APTSMD_description__c,APTSMD_Advanced_Information__c,APTSMD_instructions__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_active__c = true and APTSMD_favorite__c = true
                              Order by name asc]; 
        
        /* Initialize variables */
        category_list = new List<wCategory>();
        
        //get MDO Home Resources
        populateResources();
        /* Grab all possible picklist values for APTSMD_SDO_Tool__c.APTSMD_Category__c and create a new wCategory */
        for(Schema.PicklistEntry cat : APTSMD_SDO_Tool__c.APTSMD_Category__c.getDescribe().getPicklistValues())
            category_list.add(new wCategory(cat.getValue()));
    }
    
    //fetch the data from MDO HOme Resources object to display Resource sections
    public void  populateResources(){
            listReleaseNotes = [SELECT Id,APTSMD_Section_Name__c,Name,APTSMD_active__c,APTSMD_ResourceLogoName__c,APTSMD_Resourceurl__c FROM APTSMD_MDOHomeResources__c WHERE APTSMD_active__c=TRUE AND APTSMD_Section_Name__c = 'Release Notes'];
            listCPQ = [SELECT Id,APTSMD_Section_Name__c,Name,APTSMD_active__c,APTSMD_ResourceLogoName__c,APTSMD_Resourceurl__c FROM APTSMD_MDOHomeResources__c WHERE APTSMD_active__c=TRUE AND APTSMD_Section_Name__c = 'CPQ'];
            listCLM = [SELECT Id,APTSMD_Section_Name__c,Name,APTSMD_active__c,APTSMD_ResourceLogoName__c,APTSMD_Resourceurl__c FROM APTSMD_MDOHomeResources__c WHERE APTSMD_active__c=TRUE AND APTSMD_Section_Name__c = 'CLM'];
            listBillingRevRec = [SELECT Id,APTSMD_Section_Name__c,Name,APTSMD_active__c,APTSMD_ResourceLogoName__c,APTSMD_Resourceurl__c FROM APTSMD_MDOHomeResources__c WHERE APTSMD_active__c=TRUE AND APTSMD_Section_Name__c = 'Billing & Rev Rec'];
            listECommercePortal = [SELECT Id,APTSMD_Section_Name__c,Name,APTSMD_active__c,APTSMD_ResourceLogoName__c,APTSMD_Resourceurl__c FROM APTSMD_MDOHomeResources__c WHERE APTSMD_active__c=TRUE AND APTSMD_Section_Name__c = 'ECommerce & Portal'];
            listICPQ = [SELECT Id,APTSMD_Section_Name__c,Name,APTSMD_active__c,APTSMD_ResourceLogoName__c,APTSMD_Resourceurl__c FROM APTSMD_MDOHomeResources__c WHERE APTSMD_active__c=TRUE AND APTSMD_Section_Name__c = 'iCPQ'];
            checkSections();
    }
    public void checkSections(){
        if (listCPQ.isEmpty())
            CPQSection = false;
        else
            CPQSection = true;
        
         if (listCLM.isEmpty())
            CLMSection = false;
        else
            CLMSection = true;
        
         if (listBillingRevRec.isEmpty())
            billingSection = false;
        else
            billingSection = true;
        
         if (listECommercePortal.isEmpty())
            eCommerceSection = false;
        else
            eCommerceSection = true;
        
        if (listICPQ.isEmpty())
            iCPQSection = false;
        else
            iCPQSection = true;
    }
    
    
    /* Represents a Category * it's tools for SideNavBar */
    public class wCategory {
        public String category_title {get;set;}
        public List<APTSMD_SDO_Tool__c> category_tools {get;set;}
         
        public wCategory(String title) {
            category_title = title;
            category_tools = [Select Id, Name, APTSMD_url__c,APTSMD_description__c,APTSMD_instructions__c, APTSMD_pop_new_window__c, APTSMD_height__c, APTSMD_width__c 
                              From APTSMD_SDO_Tool__c
                              Where APTSMD_Category__c = :category_title 
                              Order by APTSMD_order__c asc];                                         

            /* Modify APTSMD_url__c for each APTSMD_SDO_Tool__c from relative to direct link */
            String s = (ApexPages.Currentpage() == null) ? 'https://na1.salesforce.com/apex/sdo_tools' : ApexPages.currentPage().getUrl();
            s = (s == null) ? 'https://na1.salesforce.com/apex/sdo_tools' : s.substring(0, s.indexOf('/'));

            for(APTSMD_SDO_Tool__c t : category_tools) {
                if(t.APTSMD_url__c.contains('http')) {
                    continue;
                } 
                t.APTSMD_url__c = (t.APTSMD_url__c.contains('/apex/')) ? s + t.APTSMD_url__c : s + '/apex/' + t.APTSMD_url__c;
                t.APTSMD_url__c = (t.APTSMD_url__c.contains('?')) ? t.APTSMD_url__c + '&isdtp=vw' : t.APTSMD_url__c + '?isdtp=vw';
            }
        }
    }    
}