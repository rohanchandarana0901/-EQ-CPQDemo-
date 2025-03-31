public class APTSMD_MDOHOMECtrl{
    public string instanceUrl{get; set;}
    public string batchUpdateAppId{get; set;}
    public String userName {get; set;}
    public String password {get; set;}
    private String orgInstance;
    
    public void oneClickPostSpin(){
        //set instance URL
        setInstanceURL();
        system.debug('ONECLICKPOSTSPIN: instance URL set');
        
        //manage users
        AssignLicenses();
        system.debug('ONECLICKPOSTSPIN: AssignLicenses done');
        
        //set backup admin user
        APTSMD_BackupUserMaintenanceController.setBackupAdminUser();
        system.debug('ONECLICKPOSTSPIN: BackupUserMaintenance done');
        
        AppMenuItem batchUpdateApp = [SELECT Id, ApplicationId, Name, Label FROM AppMenuItem WHERE Name = 'ApttusBatchUpdates'];
        batchUpdateAppId = batchUpdateApp.ApplicationId;
        System.debug('asdasd ' + batchUpdateApp.Id);
        System.debug('asdasd ' + batchUpdateApp.Name);
        System.debug('asdasd ' + batchUpdateApp.Label);
    }
    
    /* not to be included in new mdo :chetan
    public PageReference save() {     
        APTSMD_Code_Backup_Config_Setting__c customSetting = APTSMD_Code_Backup_Config_Setting__c.getInstance('System Properties');
     // User u =[select id,Name,Username from User where id =: userInfo.getUserId()];
     // System.debug('===================================================================   :   '+u);
        customSetting.APTSMD_User_Name__c = userName;
        customSetting.APTSMD_Password__c = password;
        update customSetting;
        
        userName = '';
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'User Name & Password updated successfully in Code Backup Config Setting.'));
        return null;
    }
    */
    public pageReference updateInstanceUrl(){
        
        setInstanceURL();
        updateComposerRemoteSites(orgInstance);
        setfavoriteIconID ();
        setUpForContractPortal ();
        assignApttusPromoLicense();
        assignLicenses();
        APTSMD_ExecuteMaintenanceJobs.executeAllJobs();
        
      
        APTSMD_BackupUserMaintenanceController.setBackupAdminUser();
        APTSMD_BackupUserMaintenanceController.createPrimaryUserField();
        //APTSMD_GreenTechMaintenance.updateCustomSettings();
        //APTSMD_SRMMaintenance.updateCustomSettings();
        //save();
       // APTSMD_UpdateDates();
        updateAndRedirect();
        
        //Jigar Naik 24/04/2019- Fix for incorrect category id error in MDO spins
        //return new PageReference('/apex/Apttus_Config2__HierarchyViewUpdate2');
        //added by vp on 23rd nov 2021 - set composer lightning collection
        return new PageReference('/apex/APTSMD_UpdateLightningComposerCollection');
    }
    
    //Added By Jigar Naik on 07/19/2017
    @future
    public static void assignApttusPromoLicense(){
        PackageLicense promoLicense = [SELECT Id, NamespacePrefix, ExpirationDate  from PackageLicense Where NamespacePrefix = 'Apttus_Promo'];
        
        List<UserPackageLicense> userLicenseList = [Select Id, UserId,  PackageLicenseId from UserPackageLicense Where PackageLicenseId = :promoLicense.Id];

        if(userLicenseList.isEmpty()){
            UserPackageLicense newLicenseAssignment = new UserPackageLicense();
            newLicenseAssignment.UserId = UserInfo.getUserId();
            newLicenseAssignment.PackageLicenseId = promoLicense.Id;
            insert newLicenseAssignment;
            system.debug('###User License for Apttus_Promo:' + newLicenseAssignment);
        }
    }
    
    @future(callout=true)
    public static void updateComposerRemoteSites(String orgInstance){
        Map<String, String> composerSites = new Map<String, String>();
        composerSites.put('Composer_VisualForce', 'https://' + orgInstance + '--apxtconga4.visualforce.com');
        composerSites.put('Conga_Front_End', 'https://' + orgInstance + '--apxtconga4.visualforce.com');
        composerSites.put('Standard_VisualForce', 'https://c.' + orgInstance + '--visualforce.com');
        
        new APTSMD_createRemoteSiteEndpoint().updateRemoteSiteSetting(composerSites);
    }
    
    /*Updated by vivek as on 20th Oct 2016: To updated x author for excel custom setting. Call on Line 88*/
    public void updateXAECustomSettings(){
        List<Organization> pod=[Select InstanceName From Organization];
        Apttus_XApps__XAuthorForExcelSystemProperties__c xae=Apttus_XApps__XAuthorForExcelSystemProperties__c.getInstance('System Properties');
        String podName=pod[0].InstanceName;
        String url='https://c.'+podName+'.visual.force.com';
        
        System.debug(url);
        xae.Apttus_XApps__InstanceUrl__c=url;
        update xae;        
    }
    
    public pageReference sendToDiego(){
        Contact thisContact = new Contact();
        thisContact = [SELECT FirstName, LastName FROM Contact WHERE FirstName ='Diego' AND LastName = 'Francis' LIMIT 1];

        pageReference reRouteURL = new pageReference('/'+thisContact.Id);
        
        return reRouteURL; 
    }
    
    public string enableSite{get; set;}
    
    public String getEnableSite(){
        return (new PageReference('/udd/Site/customSubdomain.apexp?isdtp=mn').getContent().toString());
    }
    
    //To uncheck the content sniffing protection
    public string uncheckContent{get; set;}
    
    public String getuncheckContent(){
        String str = URL.getSalesforceBaseUrl().toExternalForm() + '/_ui/system/security/SessionSettings?id=00D61000000fCw3?isdtp=mn';
        return str;
        //return (new PageReference('/_ui/system/security/SessionSettings?id=00D61000000fCw3?isdtp=mn').getContent().toString());
    }
    public void setInstanceURL(){
        
        
        Apttus_Approval__ApprovalsSystemProperties__c approvalsSystemProperties=Apttus_Approval__ApprovalsSystemProperties__c.getValues('System Properties');
        approvalsSystemProperties.Apttus_Approval__InstanceUrl__c=instanceUrl;
        Update approvalsSystemProperties;
        
        Apttus_Config2__ConfigSystemProperties__c configSystemProperties=Apttus_Config2__ConfigSystemProperties__c.getValues('System Properties');
        configSystemProperties.Apttus_Config2__InstanceUrl__c=instanceUrl;
        
        Update configSystemProperties;
        
        Apttus__ComplySystemProperties__c complySystemProperties=Apttus__ComplySystemProperties__c.getValues('System Properties');
        complySystemProperties.Apttus__InstanceUrl__c=instanceUrl;
        
        Update complySystemProperties;
        
        Apttus_Proposal__ProposalSystemProperties__c proposalSystemProperties=Apttus_Proposal__ProposalSystemProperties__c.getValues('System Properties');
        proposalSystemProperties.Apttus_Proposal__InstanceUrl__c=instanceUrl;
        
        Update proposalSystemProperties;
        
        Apttus_XApps__XAuthorForExcelSystemProperties__c xauthorforexcelSetting = Apttus_XApps__XAuthorForExcelSystemProperties__c.getValues('System Properties');
        xauthorforexcelSetting.Apttus_XApps__InstanceUrl__c = instanceUrl;
        
        update xauthorforexcelSetting;
        
        Apttus_Revenue2__RevenueSystemProperties__c revenueSetting = Apttus_Revenue2__RevenueSystemProperties__c.getValues('System Properties');
        revenueSetting.Apttus_Revenue2__InstanceUrl__c = instanceUrl;
        
        update revenueSetting;
        
        APTSMD_Apttus_PreSales_Config_Settings2__c preSalesSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        preSalesSetting.APTSMD_Instance_URL__c = instanceUrl;
        update preSalesSetting;
    }
    
    public void setfavoriteIconID () {
        List<product2> productlist = new list<product2>();
        productlist = [select id from product2 where name = 'Favorite'];
    
        if(productlist.size() > 0) {
            List<Attachment> attachmentList = new List<Attachment>();
            attachmentList = [select id,name from attachment where parentid=:productlist[0].id];
            
            if(attachmentList.size() > 0) {
                Apttus_Config2__ConfigSelectConfigProductsSettings__c configbundleSystemProperties=Apttus_Config2__ConfigSelectConfigProductsSettings__c.getValues('Primary Settings');
                configbundleSystemProperties.Apttus_Config2__FavoritesIconAttachmentId__c = attachmentList[0].id;
                
                Update configbundleSystemProperties;  
            }
        }  
    }
    
    //Added by Sagar Jogi - 20th june 2017. It is used to change custom setitng in contract portal
    public void setUpForContractPortal () {
        List<user> userlist = new List<user> ();
        userList = [select id,email from user where firstname = 'Tony' and lastname = 'Stark'];
        if(userList.size() > 0) {
            for(User u : userList) {
                u.Email = 'congademo@conga.com';
                u.country = null;
            }
            update userList;
        }
        

        APTSMD_AgreementPortal__c portalSetting = APTSMD_AgreementPortal__c.getValues('Portal Config');
        if(portalSetting!=null){
           ConnectApi.CommunityPage comPage = ConnectApi.Communities.getCommunities();
           string siteurl;
           for(ConnectApi.Community com : comPage.communities){
               system.debug('####### '+ com);
               if(com.urlPathPrefix != null){
                   if(com.urlPathPrefix.equalsIgnoreCase('AgreementPortal')){
                       siteurl = com.siteurl;
                   }
               }
           }
           if(siteurl != null) {
               portalSetting.APTSMD_Community_URL__c = siteurl +'#/';
               portalSetting.APTSMD_Attachment_Url__c = siteurl +'/servlet/servlet.FileDownload?file=';
               update portalSetting;
           }
           
        }
    }

    public boolean setUpdateUser {get; set;}
    //public boolean setInstanceUrl {get; set;}
    public boolean setRelplyTo{get; set;}
    public boolean setMainUserLicenses{get; set;}
    public boolean setEcommUserLicenses{get; set;}
    public boolean setDiegoLicenses{get; set;}
    public list<string> listOfEmailIds{get; set;}
    public list<string> listOfString {get; set;}
    public string defaultEmailId{get; set;}
    public string eAddress {get;set;}   
    public document logo {get; set;}
    public document portalLogo {get; set;}   
    public document logoT {get; set;}
    public document portalLogoT {get; set;}
    public string appid {get;set;}
    public list<Account> listOfAccounts {get; set;}
    public list<User> listOfUsers {get; set;}
    public APTSMD_Apttus_PreSales_Config_Settings2__c presaleConfigSetting {get; set;}
    private Organization orgDetails {get; set;} 
    public boolean setCompanyLogoInEmails {get; set;}
    public boolean setCompanyNameInEmails {get; set;}
    public boolean createPriceList {get; set;}

    public string getEmailIds(){
        string str='';
        for(string s:listOfEmailIds){
            str=str+s+',';
        }
        return str;
    }
    
    public void setEmailIds(string str){
        listOfEmailIds=new list<string>();
        for(string s:str.split(',')){
            if(s!=''){
                listOfEmailIds.add(s);
            }
        }
    }
    
    
    public string getEmailTemplates(){
        string str='';
        for(string s:listOfString ){
            str=str+s+',';
        }
        str = str.substringBeforeLast(',');
        return str;
    }
    
    public void setEmailTemplates(string str){
        listOfString =new list<string>();
        for(string s:str.split(',')){
            if(s!=''){
                listOfString.add(s);
            }
        }
    }
    
        public APTSMD_MDOHOMECtrl(){
        defaultEmailId='apttusdemo@yahoo.com';
        setEmailTemplateName();
        setListOfEmailIds();
        
        enableSite = getEnableSite(); 
            
     // Split up the hostname using the period as a delimiter
     // Possible Scenarios:
     // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, instance is 2nd part
     // (2) na12.salesforce.com      --- 3 parts, instance is 1st part
     // (3) ion.my.salesforce.com    --- 4 parts, instance is not determinable
       
        String instance;
        List<String> parts = System.URL.getSalesforceBaseUrl().getHost().split('\\.');
        if (parts.size() == 3) instance = parts[0];
        else if (parts.size() == 5)  {
            if(parts[0] == 'c') {
                instance = parts[1];
            } else {
                instance = parts[0].substringBefore('--c') + '.' + 'my';
            }
        }
        else if (parts.size() == 4) instance = parts[0]+ '.' +parts[1];
        else instance = null;
        system.debug('@@@'+parts);
        system.debug('-----'+System.URL.getCurrentRequestUrl().toExternalForm());
        
         
        if(instance.contains('--c')){
            List<String> tempInstance = instance.split('--c');
            instance=tempInstance[0]+'.my';
        }
        
        
    /*  string url1=URL.getSalesforceBaseUrl().toExternalForm();
        url1=url1.replace('//c.','//');
        url1=url1.substring(8,12);
        instanceUrl='https://na10.salesforce.com'.replace('na10',url1); */
        // CZ 
        //if(instance.endsWith('0'))
              //instance=instance.removeEnd('0');

        orgInstance = instance.split('\\.')[0];
        instanceUrl= 'https://' + instance + '.salesforce.com';

        setUpdateUser = true;
        //setInstanceUrl = true;
        setRelplyTo = true;
        setMainUserLicenses = true;
        setEcommUserLicenses = true;
        setDiegoLicenses = true;
        
        listOfAccounts=[select name,website, APTSMD_Original_Account_Name__c, APTSMD_Original_Website__c  from Account];
        
        //listOfUsers =[select Country,FirstName,LastName,email, APTSMD_Original_First_Name__c, APTSMD_Original_Last_Name__c, APTSMD_Original_email__c from User where isActive=true and LastName!='Process' And (NOT Email LIKE '%salesforce%') And (NOT Email like 'noreply%')];
        listOfUsers =[select Country,FirstName,LastName,email, APTSMD_Original_First_Name__c, APTSMD_Original_Last_Name__c, APTSMD_Original_email__c from User where isActive=true and APTSMD_Original_email__c != Null];
        
        orgDetails = [SELECT Id,   Name FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        
        presaleConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        
        if(presaleConfigSetting ==null){
             
             presaleConfigSetting=new  APTSMD_Apttus_PreSales_Config_Settings2__c();
             presaleConfigSetting.name='System Properties';
        }
        
        logoT=new document();
        portalLogoT=new document();
        SetDocuments();
        getbatchtab();
        setEmailReplytoID();
        
           
         proposaldate = true;
        avmdates = true;
        incentivedates = true;
        cssproductscope = true;
         rackUnit=true;
         updateIncentive=true;
        acceptedproposals = [Select Id, Apttus_Proposal__Presented_Date__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Approval_Stage__c='Accepted'];
        attibuteMatrices = [Select Id, Apttus_Config2__EffectiveDate__c from Apttus_Config2__AttributeValueMatrix__c];
        incentives = [Select Id, Apttus_Config2__EffectiveDate__c from Apttus_Config2__Incentive__c];
        cloudServerSolutionProduct = [Select Id from Product2 where name = 'Cloud Server Solution'];
          
         
    }
    
    /*
    public pageReference updatePresaleConfig(){        
        if(createPriceList){ 
        //System.debug('****'+ presaleConfigSetting.Default_Pricelist__c);
        //if(presaleConfigSetting.Default_Pricelist__c!=null){
            list<Apttus_Config2__PriceList__c> ls=[select id from Apttus_Config2__PriceList__c where name=:presaleConfigSetting.Default_Pricelist__c];
            
            if(ls==null || (ls!=null && ls.size()==0)){
                Apttus_Config2__PriceList__c pl=new Apttus_Config2__PriceList__c();
                pl.name=presaleConfigSetting.Default_Pricelist__c;
                insert pl;
            }
        
        }
        Upsert presaleConfigSetting ;
        return null;
    }
    */
    
    public pageReference updateOrgName(){   
        //orgDetails.Name=presaleConfigSetting.APTSMD_Company_Name__c;
        //update orgDetails; 
        Upsert presaleConfigSetting ;
        return null;
    }
    
    public pageReference cancelAccount(){
        listOfAccounts=[select name,website, APTSMD_Original_Account_Name__c, APTSMD_Original_Website__c from Account];
        return null;
    }
    
    public pageReference updateAccount(){
        for(Account acc:listOfAccounts){
            if(acc.APTSMD_Original_Account_Name__c==null || (acc.APTSMD_Original_Account_Name__c!=null && acc.APTSMD_Original_Account_Name__c=='')) acc.APTSMD_Original_Account_Name__c=acc.name;
            if(acc.APTSMD_Original_Website__c ==null || (acc.APTSMD_Original_Website__c!=null && acc.APTSMD_Original_Website__c=='')) acc.APTSMD_Original_Website__c =acc.website;
        }
        update listOfAccounts;
        return null;
    }
    
    public pageReference resetAccount(){
        for(Account acc:listOfAccounts){
            if(acc.APTSMD_Original_Account_Name__c!=null)  acc.name=acc.APTSMD_Original_Account_Name__c;
            if(acc.APTSMD_Original_Website__c!=null)  acc.website=acc.APTSMD_Original_Website__c ;
        }
        return updateAccount();
    }

    public void getbatchtab() {
         for(Schema.DescribeTabSetResult tsr : Schema.describeTabs()) {
            if(tsr.label == 'Apttus Batch Updates') {
                 List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
                 for(Schema.DescribeTabResult tr : tabDesc) {
                    if(tr.getLabel() == 'Category Maintenance')
                       appid = tr.getUrl();
                 }
            }
         }
       
    }
    
    
    public pageReference cancelUser(){
        listOfUsers =[select Country,FirstName,LastName,email, APTSMD_Original_First_Name__c, APTSMD_Original_Last_Name__c, APTSMD_Original_email__c from User where isActive=true And (NOT Email LIKE '%salesforce%')];
        return null;
    }
    
    public pageReference updateUser1(){
        // added by jeetu agrawal
        //21 feb,2019 
        listOfUsers =[select Username,Country,FirstName,LastName,email, APTSMD_Original_First_Name__c, APTSMD_Original_Last_Name__c, APTSMD_Original_email__c from User where isActive=true And Email LIKE '%example%' and APTSMD_Original_email__c != Null];
        for(User usr:listOfUsers){
            /*if(usr.email!=null && usr.email!=''){
                String email = usr.email;
                if(email.contains('example')){
                    if(email=='congademo@example.com'){
                        email='congademo@conga.com';
                    }
                    if(email=='congaapprover@example.com'){
                        email='congaapprover@conga.com';
                    }
                    
                    if(email=='congasigner@example.com'){
                        email='congasigner@conga.com';
                    }
                    
                    if(email=='demofinance@example.com'){
                        email='demofinance@conga.com';
                    }
                    
                    if(email=='demolegal@example.com'){
                        email='demolegal@conga.com';
                    }
                    
                    usr.email=email;
                }
            }*/
            usr.email = usr.APTSMD_Original_email__c;
        }
        
        for(User usr:listOfUsers){
            if(usr.APTSMD_Original_First_Name__c==null || (usr.APTSMD_Original_First_Name__c!=null && usr.APTSMD_Original_First_Name__c=='')) usr.APTSMD_Original_First_Name__c=usr.FirstName;
            if(usr.APTSMD_Original_Last_Name__c ==null || (usr.APTSMD_Original_Last_Name__c!=null && usr.APTSMD_Original_Last_Name__c=='')) usr.APTSMD_Original_Last_Name__c =usr.LastName;
            if(usr.APTSMD_Original_email__c==null || (usr.APTSMD_Original_email__c!=null && usr.APTSMD_Original_email__c=='')) usr.APTSMD_Original_email__c=usr.email; 
            usr.Country = 'United States';
        }
        update listOfUsers;
        
        User diegoUser = [select Username,FirstName from user where FirstName='Diego' limit 1];
        
        
        if(diegoUser!=null)
        {
            if(diegoUser.FirstName=='Diego')
            {
                diegoUser.Username='diegofrancis.'+UserInfo.getOrganizationId().substring(0,15)+'@congademo.com';
                update diegoUser;
            }
        }
        
        return null;
    }
    
    public pageReference resetUser(){
        for(User usr:listOfUsers){
           if(usr.APTSMD_Original_First_Name__c!=null) usr.FirstName=usr.APTSMD_Original_First_Name__c;
           if(usr.APTSMD_Original_Last_Name__c!=null) usr.LastName=usr.APTSMD_Original_Last_Name__c ;
           if(usr.APTSMD_Original_email__c!=null) usr.email=usr.APTSMD_Original_email__c ;
           usr.Country = 'United States';
        }
        return updateUser();
    }
    
    
    private void setDocuments(){
         
        
        list<document> listOfDocument=[select id,Name,DeveloperName,body,isPublic  from document where DeveloperName in ('APTSMD_Partner_Portal_Image','APTSMD_New_Apttus_logo')];
        
        if(listOfDocument==NULL || (listOfDocument!=NULL && listOfDocument.size()<=0)){
            CreateLogoRecord();
        }
        if(listOfDocument!=NULL && listOfDocument.size()>0 ){
            for(document doc:listOfDocument){
                    if(doc.name=='New Apttus logo'){
                        logo=doc;
                    }
                    else{
                        portalLogo=doc;
                    }
            }
            if(listOfDocument.size()!=2){
                CreateLogoRecord();
            } 
        }
    }
    
    public pageReference saveDocuments(){
        setDocuments();
        list<document> listOfDocument=new list<document>();
        
        
        
        logo.body=logoT.Body;
        portalLogo.body=portalLogoT.Body;
        portalLogo.isPublic  =true;
        portalLogo.Name='Partner Portal Image';
        logo.Name='New Apttus logo';
        logo.isPublic  =true;
        listOfDocument.add(logo);
        listOfDocument.add(portalLogo);
        
        //System.debug('***'+logo);
        //System.debug('***'+portalLogo);  
        
        upsert portalLogo;
        
        upsert logo;
        
        
        
        return null;
    }
    
    private void createLogoRecord(){
        if(logo==null){
            logo=new document();
            logo.Name='New Apttus logo';
            logo.DeveloperName='APTSMD_New_Apttus_logo';
            logo.ContentType = 'image/png';
            logo.Type = 'png';
            logo.FolderId=UserInfo.getUserId();
        }
        if(portalLogo==null){
            portalLogo=new document();
            portalLogo.Name='Partner Portal Image';
            portalLogo.DeveloperName='APTSMD_Partner_Portal_Image';
            portalLogo.ContentType = 'image/png';
            portalLogo.Type = 'png';
            portalLogo.FolderId=UserInfo.getUserId();
       }
    }
    
    public pageReference setListOfEmailIds(){
    
        list<string> listOfLastName=new list<string>();
        
        listOfLastName.add('Finance');
        listOfLastName.add('Legal');
        listOfLastName.add('Manager');
        listOfLastName.add('Moss');
        listOfLastName.add('Pricing');
        listOfLastName.add('Sales');                                        
        
        //System.debug('****'+ defaultEmailId);
        
        list<User> listOfUsers=[Select id, email, name from user where isActive=true   and email!=:defaultEmailId];//and lastName in :listOfLastName
        
        listOfEmailIds=new list<string>();
        
        for(User us: listOfUsers){
            listOfEmailIds.add(us.email);
        }
        
        return null;
    }
    
    public PageReference UpdateUser() {
        list<User> listOfUsers=[Select id, email, name from user where isActive=true and email in :listOfEmailIds];
        
        for(User us: listOfUsers){
            us.email=defaultEmailId;
        }
         
        update listOfUsers;
        return null;
    }
    
    public pageReference clickMe(){
    
        setInstanceURL();
        
        return null;
        
         
        
    }
    
     public pageReference process(){
    
        if(setUpdateUser) 
            UpdateUser();  
        return null;
        
         
        
    }
    
     
    //Added by Jeetu Agrawal
    //09/08/2019
    Public pageReference setAgreementEmailService(){
        EmailServicesFunction agreementFun = [select id,FunctionName FROM EmailServicesFunction Where FunctionName ='AgreementEndParallelReviewByEmailService' limit 1];
        if(agreementFun!=null)
        {
            EmailServicesAddress agreementService = [SELECT LocalPart, EmailDomainName  FROM EmailServicesAddress where Functionid=:agreementFun.id limit 1];
            if(agreementService!=null)
            {
                String agrService = agreementService.LocalPart+'@'+agreementService.EmailDomainName;
                Apttus__APTS_Admin__c adminEntry = [select id,name,Apttus__Value__c from Apttus__APTS_Admin__c where name='APTS_EndReviewEmailServiceAddress' limit 1];
                if(adminEntry!=null)
                {
                    adminEntry.Apttus__Value__c=agrService;
                    update adminEntry;
                }
            }
        }
        
        // For ApttusEndReviewByEmailO365 Email Service
        EmailServicesFunction agreementFun1 = [select id,FunctionName FROM EmailServicesFunction Where FunctionName ='ApttusEndReviewByEmailO365' limit 1];
        if(agreementFun1!=null)
        {
            EmailServicesAddress agreementService1 = [SELECT LocalPart, EmailDomainName  FROM EmailServicesAddress where Functionid =: agreementFun1.id limit 1];
            if(agreementService1!=null)
            {
                String agrService = agreementService1.LocalPart+'@'+agreementService1.EmailDomainName;
                Apttus__APTS_Admin__c adminEntry = [select id,name,Apttus__Value__c from Apttus__APTS_Admin__c where name='APTS_EndOffice365ReviewEmailServiceAddress' limit 1];
                if(adminEntry!=null)
                {
                    adminEntry.Apttus__Value__c=agrService;
                    update adminEntry;
                }
            }
        }
        
        return null;
    }
    
    public pageReference processEmailReplyto(){
        System.debug('listOfString : '+listOfString);
        setEmailReplyto(); 
        //Modification by sagar jogi - 20-01-2016--- start
          APTSMD_SetEmailIdInSystemProperties.SetReplytoEmailId();
        //Modification by sagar jogi - 20-01-2016--- end
        
        return null;
    }
   
    public document getCompanyLogoDocument(String logo_name){
        list<document> listOfDocuments= [SELECT Body, Id, Name, AuthorId, BodyLength, CreatedById, CreatedDate, IsDeleted, Description, IsBodySearchable, DeveloperName, IsPublic, Type, FolderId, IsInternalUseOnly, Keywords, LastModifiedById, LastModifiedDate, ContentType, NamespacePrefix, SystemModstamp, Url FROM Document WHERE Name = :logo_name LIMIT 1];
        if(listOfDocuments!=null && listOfDocuments.size()>0){
            return listOfDocuments[0];
        }
        return null;
    }
     
    //This method will assign all the Apttus package licenses to the main user and the eComm Site Guest User
    public void assignLicenses() {

        Id thisUserId = UserInfo.getUserId();
        User user1 = new User();
        user1 = [SELECT Id FROM User WHERE Id =: thisUserId];               //main user
        User user2 = new User();
        user2 = [SELECT Id, Profile.Name FROM User WHERE Profile.Name = 'Ecommerce New Profile']; //eComm Site Guest User
        List<User> users = new List<User>();
        User user3 = new User();
        user3 = [SELECT Id, Name FROM User WHERE FirstName='Diego' AND LastName='Francis']; //Diego Francis


        //All the package licenses that must be assigned to the users
        List<PackageLicense> licenseList = new List<PackageLicense>([SELECT Id, 
                                    NamespacePrefix 
                               FROM PackageLicense 
                              WHERE NamespacePrefix = 'Apttus_Approval'
                                OR NamespacePrefix = 'Apttus_Config2'
                                OR NamespacePrefix = 'Apttus_Proposal'
                                OR NamespacePrefix = 'Apttus_Promo'
                                OR NamespacePrefix = 'Apttus_QPConfig']);

        List<UserPackageLicense> uplList = new List<UserPackageLicense>();      
        List<UserPackageLicense> uplListToInsert = new List<UserPackageLicense>();     //list of UserPackageLicenses to insert

        uplList = [SELECT PackageLicenseId,
                          UserId
                     FROM UserPackageLicense];

        Set<String> uplCombos = new Set<String>();
        for (UserPackageLicense temp : uplList){
            uplCombos.add(''+temp.PackageLicenseId+temp.UserId);
        }

        if(setMainUserLicenses){
            for(PackageLicense pl : licenseList){               //assign all the necessary licenses to the main user
                UserPackageLicense upl = new UserPackageLicense();
                upl.PackageLicenseId = pl.Id;
                upl.UserId = user1.Id;
                if(!uplCombos.contains(''+upl.PackageLicenseId+upl.UserId)){
                    uplListToInsert.add(upl);
                }
            }
        }
        if(setEcommUserLicenses){
            for(PackageLicense pl : licenseList){               //assign all the necessary licenses to the main user
                UserPackageLicense upl = new UserPackageLicense();
                upl.PackageLicenseId = pl.Id;
                upl.UserId = user2.Id;
                if(!uplCombos.contains(''+upl.PackageLicenseId+upl.UserId)){
                    uplListToInsert.add(upl);
                }
            }
        }
        if(setDiegoLicenses){
            for(PackageLicense pl : licenseList){               //assign all the necessary licenses to the main user
                UserPackageLicense upl = new UserPackageLicense();
                upl.PackageLicenseId = pl.Id;
                upl.UserId = user3.Id;
                if(!uplCombos.contains(''+upl.PackageLicenseId+upl.UserId)){
                    uplListToInsert.add(upl);
                }
            }
        }

        try{
            insert uplListToInsert;
        }catch(Exception e){

        }
    }
     
     
    private void setEmailReplytoID() {

      EmailServicesFunction emailService;
      list<EmailServicesFunction> listOfEmailServices= new list<EmailServicesFunction>();
      listOfEmailServices = [SELECT  Id  FROM EmailServicesFunction Where FunctionName ='Email Approval Services'];
      if(listOfEmailServices!=null && listOfEmailServices.size()>0) {
        emailService=listOfEmailServices[0];
      } else {
    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Add Email Services for email to approval to work.'));
      }
        
        EmailServicesAddress  emailAddress;
        
        list<EmailServicesAddress> listOfEmailAddresses = new list<EmailServicesAddress>();
        
        if(emailService!=null) 
            listOfEmailAddresses=[SELECT AuthorizedSenders,  LocalPart, EmailDomainName  FROM EmailServicesAddress where Functionid=:emailService.id];
        if(listOfEmailAddresses!=null && listOfEmailAddresses.size()>0) {
            emailAddress=listOfEmailAddresses[0];

            eAddress=emailAddress.LocalPart+'@'+emailAddress.EmailDomainName;
            } else {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Add Email address under email service for email to approval to work.'));
            }

    } 


    private void setEmailReplyto(){
            
       String apexImageTagText = 'apex:image';
       String replyToText = 'replyTo=';
       
        list<EmailTemplate> ListOfET=[SELECT Id, Name, Markup FROM EmailTemplate where name in :listOfString];
        System.debug('ListOfET : '+ListOfET + 'size  == '+ListOfET.size());
        list<EmailTemplate> ListOfETToUpdate = new List<EmailTemplate>();
        document getLogoDoc = getCompanyLogoDocument('New Apttus Logo');
        System.debug(ListOfET);
        for (EmailTemplate ET:ListOfET){
            System.debug('ET name : '+ET.name);
            Boolean toUpdate = false;

            DOM.Document doc = new DOM.Document();   
            
            string MarkUp=ET.Markup; 
            System.debug('MarkUp: '+Markup);
             
            //string eAddress=EmailAddress.LocalPart+'@'+EmailAddress.EmailDomainName;
            
            //System.debug('***'+ ET.id);

            
            if(setCompanyLogoInEmails && MarkUp != null){
                String documentURLToReplace = getDocumentURLToReplace(MarkUp);
                string documentURL=URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id=' + getLogoDoc.ID + '&oid='+orgDetails.id;
                //System.debug('documentURL: '+ documentURL);
                //System.debug('documentURLToReplace: '+documentURLToReplace);
                if(markUp != null && MarkUp.contains(apexImageTagText)){
                    MarkUp= MarkUp.replace(documentURLToReplace,documentURL);
                    ET.Markup=MarkUP;
                    toUpdate = true;
                }
            }
            
            if(setCompanyNameInEmails && PresaleConfigSetting!=null && PresaleConfigSetting.APTSMD_Company_Name__c!=null && MarkUp != null) { 
             
                ET.MarkUp= MarkUp.replace('Company_Name',PresaleConfigSetting.APTSMD_Company_Name__c);
                toUpdate = true;
                 
            }


            
          //  string finalMarkUp=walkThrough(MarkUp,eAddress) ; 
            
          //  ET.Markup= finalMarkUp ;  
            if(setRelplyTo){
                 //System.debug('eAddress '+ eAddress);
                    String eAddressToReplace = getEmailAddressToReplace(MarkUp);
                    //System.debug('eAddressToReplace: ' + eAddressToReplace);
                    if((markUp != null && markUp.indexOf('replyTo=')<0) || (markUp!=null && markUp.indexOf('replyTo=')>0 && markUp.indexOf(eAddress)<0)){
                        //System.debug('eAddressToReplace: '+eAddressToReplace+' eAddress: '+eAddress);
                        if(eAddressToReplace != null){
                           // ET.Markup=MarkUp.replace(eAddressToReplace,eAddress);
                           ET.Markup=eAddressToReplace;
                            toUpdate = true;
                            System.debug(' coconut ^^^^ eAddressToReplace: '+ eAddressToReplace);
                            System.debug('coconut ^^^^ eAddress: '+ eAddress);
                            System.debug('coconut Second Markup: '+ET.Markup);
                        }
                    }
            }

               if(toUpdate == true) {
                   ListOfETToUpdate.add(ET);
               }
           }
           if(ListOfETToUpdate.size() > 0) {
                Update ListOfETToUpdate;

           }
                System.debug('ListOfET: '+ListOfET);
        }
        
        
        
        Public String getDocumentURLToReplace(String markUp){
        System.debug('Hiiiii '+markUp);
            String documentURLToReplace;
            String apexImageTagText = 'apex:image';
            Integer indexOfStartLink;
            Integer indexAfterEndLink;
            String quote = '"';
            if(markUp.contains(apexImageTagText)){
                indexOfStartLink = markUp.indexOf(apexImageTagText);
                documentURLToReplace = markUp.substring(indexOfStartLink, (indexOfStartLink+200));
                indexOfStartLink = (documentURLToReplace.indexOf('url=')) + 4;
                indexAfterEndLink = (documentURLToReplace.indexOf('width'));
                documentURLToReplace = documentURLToReplace.substring(indexOfStartLink, indexAfterEndLink);
                documentURLToReplace = documentURLToReplace.trim();
                documentURLToReplace = documentURLToReplace.replaceAll(quote, '');
                //System.debug(documentURLToReplace);
            }
            return documentURLToReplace;

        }

        Public String getEmailAddressToReplace(String markUp){
            System.debug('inside getEmailAddressToReplace markUp: '+markUp);
            String emailAddressToReplace;
            String replyToText = 'replyTo=';
            String endChevron = '>';
            String quote = '"';
            String languageText = 'language="';
            //System.debug(quote);
            Integer indexOfAfterStartQuotes;
            Integer indexOfEndQuotes;
            
            
            if((markUp != null && markUp.indexOf('replyTo=')<0) || (markUp!=null && markUp.indexOf('replyTo=')>0 && markUp.indexOf(eAddress)<0)){
                indexOfAfterStartQuotes = (markUp.indexOf('LocaleKey}"')) + 12;
                indexOfEndQuotes = (markUp.indexOf(endChevron));
                String firstPart = markUp.substring(0,indexOfAfterStartQuotes);
                if(firstPart.indexOf('>')>0){
                    firstPart=markUp.substring(0,indexOfAfterStartQuotes-1);
                }
                String endPart = markUp.substring(indexOfEndQuotes,markUp.length());
        
                emailAddressToReplace=firstPart + ' replyTo="'+eAddress+'" '+endPart;
                
        }
            System.debug('emailAddressToReplace : '+emailAddressToReplace);
            return emailAddressToReplace;
        }

        Public id getUserId(){
            return UserInfo.getUserId();
        }
        
        public id getClassid(){
            list<apexclass> listOfApexClasses=[select id from apexClass where name='ApprovalEmailHandler' and NamespacePrefix='Apttus_Approval'];
            return listOfApexClasses[0].id;
        }
        
     
        
        private void setEmailTemplateName(){
            
            List<Apttus_Approval__Approval_Process__c> approvalList = [select id,name,Apttus_Approval__Process_Name__c,Apttus_Approval__Assignment_Email_Template__c,Apttus_Approval__Cancellation_Email_Template__c,Apttus_Approval__Escalation_Email_Template__c,Apttus_Approval__NotifyOnly_Email_Template__c,Apttus_Approval__Reassignment_Email_Template__c from Apttus_Approval__Approval_Process__c where Apttus_Approval__Process_Name__c!=''];
            listOfString=new list<string>();
            Set<String> listofTemplateName = new Set<String>();
            
            for(Apttus_Approval__Approval_Process__c temp:approvalList){
                if(temp.Apttus_Approval__Assignment_Email_Template__c!=null){
                    listofTemplateName.add(temp.Apttus_Approval__Assignment_Email_Template__c);
                }
                
                if(temp.Apttus_Approval__Cancellation_Email_Template__c!=null){
                    listofTemplateName.add(temp.Apttus_Approval__Cancellation_Email_Template__c);
                }
                
                if(temp.Apttus_Approval__Escalation_Email_Template__c!=null){
                    listofTemplateName.add(temp.Apttus_Approval__Escalation_Email_Template__c);
                }
                
                if(temp.Apttus_Approval__NotifyOnly_Email_Template__c!=null){
                    listofTemplateName.add(temp.Apttus_Approval__NotifyOnly_Email_Template__c);
                }
                
                if(temp.Apttus_Approval__Reassignment_Email_Template__c!=null){
                    listofTemplateName.add(temp.Apttus_Approval__Reassignment_Email_Template__c);
                }
            }
            
            if(listofTemplateName.size()>0){
                for(String temp:listofTemplateName){
                    listOfString.add(temp);
                }
            }
            
            
            //listOfString.Add('Cart Approval Notification');
            //listOfString.Add('Quote Approval Notification');
            // listOfString.Add('Apttus Quote Approval Notification (Assignment)');    
            // listOfString.Add('Apttus Agreement Approval Notification (Assignment)');        
            // listOfString.Add('Apttus Opportunity Approval Notification (Assignment)');   
          //listOfString.Add('Apttus Deal Approval Notification (Assignment)');      
            // listOfString.Add('Apttus Agreement Term Exception Approval Notification (Assignment)');
         // listOfString.Add('Cart Approval Notification - SP');  
            //listOfString.Add('Cart Approval Notification With ICM - SP');
            
            
            // listOfString.add('Apttus Agreement Approval Notification with Attachment');
            // listOfString.add('Apttus Cart Line Item Approval Notification (Assignment)');
            // listOfString.add('Apttus Cart Line Item Approval Notification (Reassignment)');
            // listOfString.add('Apttus Cart Line Item Approval Notification (Escalation)');
            // listOfString.add('Apttus Cart Line Item Approval Notification (Cancellation)');
            // listOfString.add('Apttus Cart Line Item Approval Notification (Notify Only)');
            //  listOfString.add('Apttus Cart Approval Notification (Assignment)');
            // listOfString.add('Apttus Cart Approval Notification (Reassignment)');
            // listOfString.add('Apttus Cart Approval Notification (Escalation)');
            // listOfString.add('Apttus Cart Approval Notification (Cancellation)');
            // listOfString.add('Apttus Cart Approval Notification (Notify Only)');
        }
        
        
        
        
        
        
        List<Apttus_Proposal__Proposal__c> acceptedproposals;
    List<Apttus_Config2__AttributeValueMatrix__c> attibuteMatrices;
    List<Apttus_Config2__Incentive__c> incentives;
    List<Apttus_Config2__AttributeValueMatrix__c> avmForCloudServerSolutionList;
    Product2 cloudServerSolutionProduct;
    public Boolean proposaldate {get;set;}
    public Boolean avmdates {get;set;}
    public Boolean incentivedates {get;set;}
    public Boolean cssproductscope {get;set;}
    public Boolean rackUnit {get;set;}
    public Boolean updateIncentive {get;set;}
        
        
        
        public PageReference updateAndRedirect(){
       /* if(!acceptedproposals.isEmpty() && proposaldate){
            for(Apttus_Proposal__Proposal__c proposal : acceptedproposals){
                proposal.Apttus_Proposal__Presented_Date__c = Date.today();
            }
            
            update acceptedproposals;
        }*/
        
        if(!attibuteMatrices.isEmpty() && avmdates){
            for(Apttus_Config2__AttributeValueMatrix__c attributematrix : attibuteMatrices){
                attributematrix.Apttus_Config2__EffectiveDate__c = Date.today()-10;
            }
            
            update attibuteMatrices;
        }
        
        if(!incentives.isEmpty() && incentivedates){
            for(Apttus_Config2__Incentive__c incentive : incentives){
                incentive.Apttus_Config2__EffectiveDate__c = Date.today()-10;
            }
            
            try{update incentives;}catch(Exception ex){}
        }
        
        if(cssproductscope){
            avmForCloudServerSolutionList = [Select Id, Apttus_Config2__ProductScope__c from Apttus_Config2__AttributeValueMatrix__c where name in('Attribute Value Matrix for Cloud Server Solution', 'Attribute Value Matrix for Cloud Server Solution - Package Specific Defaults', 'Allow 1-3 Sec and Sub-seconds for High Availability and all for rest') limit 3];
            
            for(Apttus_Config2__AttributeValueMatrix__c avmForCloudServerSolution : avmForCloudServerSolutionList){
                if(avmForCloudServerSolution != null && cssproductscope && cloudServerSolutionProduct != null){
                    avmForCloudServerSolution.Apttus_Config2__ProductScope__c = cloudServerSolutionProduct.Id;
                }
            }
            update avmForCloudServerSolutionList;
        }
        
          if(rackUnit){
        
                    List<Apttus_Config2__ProductAttributeGroupMember__c> productAttributeList = [select Apttus_Config2__AttributeGroupId__c,Apttus_Config2__FieldUpdateCriteriaIds__c,Apttus_Config2__ProductId__c from Apttus_Config2__ProductAttributeGroupMember__c where Apttus_Config2__AttributeGroupId__r.Name = 'Rack Units']; 
                    List<Apttus_Config2__FieldExpression__c> fieldExpressionList = new List<Apttus_Config2__FieldExpression__c>();
                    System.debug('productAttributeList == '+productAttributeList);
                    for(Apttus_Config2__ProductAttributeGroupMember__c temp : productAttributeList){
                        Apttus_Config2__FieldExpression__c insertExpression = new Apttus_Config2__FieldExpression__c();
                        insertExpression.name='Expression for Rack_Units__c';
                        insertExpression.Apttus_Config2__ProductId__c=temp.Apttus_Config2__ProductId__c;
                        insertExpression.Apttus_Config2__UpdateField__c='Apttus_Config2__AttributeValueId__r.APTSMD_Rack_Units__c';
                        insertExpression.Apttus_Config2__Expression__c='2';
                        insertExpression.Apttus_Config2__ExpressionType__c='Field Update';
                        insertExpression.Apttus_Config2__Active__c=true;
                        insertExpression.Apttus_Config2__EvaluationContext__c='Record Update';
                        insertExpression.Apttus_Config2__SourceObject__c='Apttus_Config2__LineItem__c';
                        insertExpression.Apttus_Config2__UpdateObject__c='Apttus_Config2__LineItem__c';
                        fieldExpressionList.add(insertExpression);
                    }
                    System.debug('productAttributeList == '+productAttributeList);
                    System.debug('fieldExpressionList == '+fieldExpressionList);
                    insert fieldExpressionList;
                    
                    integer count=0;
                    
                    for(Apttus_Config2__ProductAttributeGroupMember__c temp : productAttributeList){
                        temp.Apttus_Config2__FieldUpdateCriteriaIds__c = '["'+fieldExpressionList.get(count).id+'"]';
                        count++;
                    }
                    
                    update productAttributeList;
                    
                     productAttributeList = [select Apttus_Config2__AttributeGroupId__c,Apttus_Config2__FieldUpdateCriteriaIds__c,Apttus_Config2__ProductId__c from Apttus_Config2__ProductAttributeGroupMember__c where Apttus_Config2__AttributeGroupId__r.Name = 'Total Rack Units']; 
                    fieldExpressionList = new List<Apttus_Config2__FieldExpression__c>();
                    System.debug('productAttributeList == '+productAttributeList);
                    for(Apttus_Config2__ProductAttributeGroupMember__c temp : productAttributeList){
                        Apttus_Config2__FieldExpression__c insertExpression = new Apttus_Config2__FieldExpression__c();
                        insertExpression.name='Expression for Total_Rack_Units__c';
                        insertExpression.Apttus_Config2__ProductId__c=temp.Apttus_Config2__ProductId__c;
                        insertExpression.Apttus_Config2__UpdateField__c='Apttus_Config2__AttributeValueId__r.APTSMD_Total_Rack_Units__c';
                        insertExpression.Apttus_Config2__Expression__c='$.$Rollups[\'Name\',\'RackRollup\'].Apttus_Config2__TotalQuantity__c';
                        insertExpression.Apttus_Config2__ExpressionType__c='Field Update';
                        insertExpression.Apttus_Config2__Active__c=true;
                        insertExpression.Apttus_Config2__EvaluationContext__c='Record Update';
                        insertExpression.Apttus_Config2__SourceObject__c='Apttus_Config2__LineItem__c';
                        insertExpression.Apttus_Config2__UpdateObject__c='Apttus_Config2__LineItem__c';
                        fieldExpressionList.add(insertExpression);
                    }
                    
                     insert fieldExpressionList;
                     
                     count=0;
                    
                    for(Apttus_Config2__ProductAttributeGroupMember__c temp : productAttributeList){
                        temp.Apttus_Config2__FieldUpdateCriteriaIds__c = '["'+fieldExpressionList.get(count).id+'"]';
                        count++;
                    }
                    
                    update productAttributeList;
        }
        
        if(updateIncentive){
            List<Apttus_Config2__IncentiveCoupon__c> incentiveCouponList = [Select Id, Apttus_Config2__AssignedToID__c, Apttus_Config2__EffectiveDate__c, Apttus_Config2__ExpirationDate__c from Apttus_Config2__IncentiveCoupon__c where Apttus_Config2__AssignedToDimensionId__r.Name = 'User'];

            if(!incentiveCouponList.isEmpty()){
                for(Apttus_Config2__IncentiveCoupon__c incentiveCoupon : incentiveCouponList){
                    incentiveCoupon.Apttus_Config2__AssignedToID__c = UserInfo.getUserId();
                    incentiveCoupon.Apttus_Config2__EffectiveDate__c = Date.today().toStartOfMonth();
                    incentiveCoupon.Apttus_Config2__ExpirationDate__c = Date.today().toStartOfMonth().addYears(1) - 1;
                }
                
                update incentiveCouponList;
            }
            
            Apttus_Config2__Incentive__c incentiveObj = [select id,Apttus_Config2__ProductScope__c from Apttus_Config2__Incentive__c where name='Buy 5, Get 1 Free (Certs)' limit 1];
            List<product2> productList = [select id,name from product2 where name='Admin Certification' or name='End User Certification' order by name];
            Apttus_Config2__PriceRuleset__c priceRuleSetObj;
            if(incentiveObj!=null){
                priceRuleSetObj = [select id from Apttus_Config2__PriceRuleset__c where Apttus_Config2__IncentiveId__c=:incentiveObj.id limit 1];
            }
            
            Apttus_Config2__PriceRule__c priceRuleObj;
            
            if(priceRuleSetObj!=null){
                priceRuleObj = [select id,Apttus_Config2__ProductCriteria__c from Apttus_Config2__PriceRule__c where Apttus_Config2__RulesetId__c=:priceRuleSetObj.id limit 1];
            }
            
            Apttus_Config2__PriceRuleEntry__c priceRuleEntry;
             
            if(priceRuleObj!=null){
                id priceRuleId = priceRuleObj.id;
                priceRuleEntry = [select id,Apttus_Config2__Products__c from Apttus_Config2__PriceRuleEntry__c where Apttus_Config2__PriceRuleId__c=:priceRuleId limit 1];    
            }
            
            
            if(incentiveObj!=null){
                if(productList.size()>0){
                    String productId ='';
                    Integer count=1;
                    for(product2 temp:productList){
                        productId=productId+temp.id;
                        if(count<productList.size()){
                            productId=productId+';';
                            count=count+1;
                        }
                        
                        if(priceRuleObj!=null){
                            if(temp.name=='End User Certification'){
                                priceRuleObj.Apttus_Config2__ProductCriteria__c=temp.id;
                            }
                        }
                        
                        if(priceRuleEntry!=null){
                            if(temp.name=='Admin Certification'){
                                priceRuleEntry.Apttus_Config2__Products__c=temp.id;
                            }
                        }
                    }
                    incentiveObj.Apttus_Config2__ProductScope__c=productId;
                }
                
                update incentiveObj;
                if(priceRuleEntry!=null){
                    update priceRuleEntry;
                }
                
                if(priceRuleObj!=null){
                    update priceRuleObj;
                }
            }
        }
        
        updateBeCreativePromotion();
        updateBuy5Get1Tier1Promotion();//added by vivek on 18 april 2022 to update product scope of newly created For Every X Get X promotion 
        
        return null;
    }
    
    private void updateBeCreativePromotion(){
        Apttus_Config2__Incentive__c incentiveObj = [select id,Apttus_Config2__ProductScope__c from Apttus_Config2__Incentive__c where name='Be Creative' limit 1];
        List<product2> productList = [select id,name from product2 where name='Creative Services' or name='Solution Architect' order by name];
        Apttus_Config2__PriceRuleset__c priceRuleSetObj;
        if(incentiveObj!=null){
            priceRuleSetObj = [select id from Apttus_Config2__PriceRuleset__c where Apttus_Config2__IncentiveId__c=:incentiveObj.id limit 1];
        }
        
        Apttus_Config2__PriceRule__c priceRuleObj;
        
        if(priceRuleSetObj!=null){
            priceRuleObj = [select id,Apttus_Config2__ProductCriteria__c from Apttus_Config2__PriceRule__c where Apttus_Config2__RulesetId__c=:priceRuleSetObj.id limit 1];
        }
        
        Apttus_Config2__PriceRuleEntry__c priceRuleEntry;
         
        if(priceRuleObj!=null){
            id priceRuleId = priceRuleObj.id;
            priceRuleEntry = [select id,Apttus_Config2__Products__c from Apttus_Config2__PriceRuleEntry__c where Apttus_Config2__PriceRuleId__c=:priceRuleId limit 1];    
        }
        
        
        if(incentiveObj!=null){
            if(productList.size()>0){
                String productId ='';
                Integer count=1;
                for(product2 temp:productList){
                    productId=productId+temp.id;
                    if(count<productList.size()){
                        productId=productId+';';
                        count=count+1;
                    }
                    
                    if(priceRuleEntry!=null){
                        if(temp.name=='Solution Architect'){
                            priceRuleEntry.Apttus_Config2__Products__c=temp.id;
                        }
                    }
                }
                incentiveObj.Apttus_Config2__ProductScope__c=productId;
                priceRuleObj.Apttus_Config2__ProductCriteria__c=productId;
            }
            
            update incentiveObj;
            if(priceRuleEntry!=null){
                update priceRuleEntry;
            }
            
            if(priceRuleObj!=null){
                update priceRuleObj;
            }
        }
    }

    //added by vivek on 18 april 2022 to update product scope of newly created For Every X Get X promotion     
    private void updateBuy5Get1Tier1Promotion(){
        Apttus_Config2__Incentive__c incentiveObj = [select id,Apttus_Config2__ProductScope__c from Apttus_Config2__Incentive__c where name='Buy 5, Get 1 Free Tier1 University' limit 1];
        List<product2> productList = [select id,name from product2 where name='Tier1 University' order by name];
        Apttus_Config2__PriceRuleset__c priceRuleSetObj;
        if(incentiveObj!=null){
            priceRuleSetObj = [select id from Apttus_Config2__PriceRuleset__c where Apttus_Config2__IncentiveId__c=:incentiveObj.id limit 1];
        }
        
        Apttus_Config2__PriceRule__c priceRuleObj;
        
        if(priceRuleSetObj!=null){
            priceRuleObj = [select id,Apttus_Config2__ProductCriteria__c from Apttus_Config2__PriceRule__c where Apttus_Config2__RulesetId__c=:priceRuleSetObj.id limit 1];
        }
        
        Apttus_Config2__PriceRuleEntry__c priceRuleEntry;
         
        if(priceRuleObj!=null){
            id priceRuleId = priceRuleObj.id;
            priceRuleEntry = [select id,Apttus_Config2__Products__c from Apttus_Config2__PriceRuleEntry__c where Apttus_Config2__PriceRuleId__c=:priceRuleId limit 1];    
        }
        if(incentiveObj!=null){
            if(productList.size()>0){
                String productId ='';
                Integer count=1;
                for(product2 temp:productList){
                    productId=productId+temp.id;
                    if(count<productList.size()){
                        productId=productId+';';
                        count=count+1;
                    }
                    
                    if(priceRuleObj!=null){
                        if(temp.name=='Tier1 University'){
                            priceRuleObj.Apttus_Config2__ProductCriteria__c=temp.id;
                        }
                    }
                }
                incentiveObj.Apttus_Config2__ProductScope__c=productId;
            }
            
            update incentiveObj;
           
            
            if(priceRuleObj!=null){
                update priceRuleObj;
            }
        }
    }
}