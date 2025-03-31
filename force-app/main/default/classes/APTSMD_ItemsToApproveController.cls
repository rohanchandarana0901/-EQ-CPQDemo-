public class APTSMD_ItemsToApproveController {

    @AuraEnabled
    public static List<Apttus_Approval__Approval_Request__c> getAllApprovalRequests(String appName){
        System.debug('##### : '+appName);
        Set<String> objectNames = New Set<String>();
        if(appName == 'CLM_Home'){
            objectNames.add('Apttus__APTS_Agreement__c');
            objectNames.add('Apttus__Agreement_Clause__c');
            objectNames.add('Apttus__Agreement_Term_Exception__c');
        }
        else if(appName == 'CPQ_Home'){
            objectNames.add('Apttus_Proposal__Proposal__c');
            objectNames.add('Apttus_Config2__ProductConfiguration__c');
            objectNames.add('Apttus_Config2__LineItem__c');
        }
        else{
            objectNames.add('Apttus__APTS_Agreement__c');
            objectNames.add('Apttus__Agreement_Clause__c');
            objectNames.add('Apttus__Agreement_Term_Exception__c');
            objectNames.add('Apttus_Proposal__Proposal__c');
            objectNames.add('Apttus_Config2__ProductConfiguration__c');
            objectNames.add('Apttus_Config2__LineItem__c');
        }
        return [SELECT id,Apttus_Approval__Object_Id__c,Apttus_Approval__Object_Id_Link__c,Apttus_Approval__Object_Name__c
                ,Apttus_Approval__Object_Type__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__SubmissionComment1__c,
                Apttus_Approval__DateAssigned__c,Apttus_Approval__Approval_Status__c
                FROM Apttus_Approval__Approval_Request__c
                WHERE (Apttus_Approval__Approval_Status__c = 'Assigned' OR Apttus_Approval__Approval_Status__c = 'Reassigned')
                AND Apttus_Approval__Assigned_To_Id__c =: UserInfo.getUserId()
                AND Apttus_Approval__Object_Type__c IN : objectNames
                ORDER BY Apttus_Approval__DateAssigned__c
                LIMIT 5];
    }
    
    //added by vivek as on 19 jan 2022 to check MFA status
    @AuraEnabled
    public static string updateMFADemoUsers(){
        APTSMD_DemoUserHelperCtrl helper = new APTSMD_DemoUserHelperCtrl();
        return json.serialize(helper.autoAssigLicense());
    }

    @AuraEnabled
    public static string packageLicenseExpiration(){
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting=APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        boolean packageLicenceExpirationEnabled=presalesConfigSetting.APTSMD_EnablePackageExpiryNotification__c;
        if(packageLicenceExpirationEnabled){
            integer dayInterval=Integer.valueOf(presalesConfigSetting.APTSMD_PackageExpiryNotificationInterval__c);
            integer daysRemaining;
            datetime intervalDatetime= datetime.now().addDays(-1*dayInterval);
            List<PackageLicense> packageLicenseList=[SELECT Id,CreatedDate,ExpirationDate,NamespacePrefix,Status FROM PackageLicense WHERE (NamespacePrefix like 'Apttus%' OR NamespacePrefix in ('APXT_CongaSign', 'APXTConga4', 'CRMC_PP', 'FSTR', 'APXT_Redlining')) AND NamespacePrefix != 'Apttus_XAAdmin' AND NamespacePrefix != 'Apttus_Collab' AND ExpirationDate >=: intervalDatetime Order By NamespacePrefix];//
            system.debug('packageLicenseList');
            system.debug(packageLicenseList);
            list<expirationwrapCls> pkgexpiryWrapList=new list<expirationwrapCls>();
            for(PackageLicense pkglicense:packageLicenseList){
                daysRemaining=(system.today()).daysBetween(Date.valueOf(pkglicense.ExpirationDate));
                pkgexpiryWrapList.add(new expirationwrapCls(pkglicense.NamespacePrefix,dayInterval,daysRemaining,pkglicense.status,pkglicense.ExpirationDate));
            }
            system.debug('pkgexpiryWrapList');
            system.debug(pkgexpiryWrapList);
            return json.serialize(pkgexpiryWrapList);
        }
        else{
            return '[]';
        }
        
    }
    
    @AuraEnabled
    public static string orgExpiration(){
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting=APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        boolean orgExpirationEnabled=presalesConfigSetting.APTSMD_EnableOrgExpirationNotification__c;
        if(orgExpirationEnabled){
            integer dayInterval=Integer.valueOf(presalesConfigSetting.APTSMD_OrgExpirationNotificationInterval__c);
            datetime intervalDatetime= datetime.now().addDays(-1*dayInterval);
            integer daysRemaining;
            List<Organization> orgDetailList = [Select Id,Name,TrialExpirationDate from Organization WHERE TrialExpirationDate >=: intervalDatetime];
            list<expirationwrapCls> orgexpiryWrapList=new list<expirationwrapCls>();
            for(Organization orglicense:orgDetailList){
                daysRemaining=(system.today()).daysBetween(Date.valueOf(orglicense.TrialExpirationDate));
                orgexpiryWrapList.add(new expirationwrapCls(orglicense.Name,dayInterval,daysRemaining,null,orglicense.TrialExpirationDate));
            }
            return json.serialize(orgexpiryWrapList); 
        }
        else{
            return '[]';
        }   
    }
    
    @AuraEnabled
    public static String getEmailLimitStatus(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.APTSMD_GetSessionId;
        // Get the content of the VF page
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
        endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        
        //Define http Request 
        //append your Query to the base url
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v44.0/limits');
        req.setMethod('GET');
        
        //Get SessionId
        string autho = 'OAuth ' + sessionId;
        req.setHeader('Authorization', autho);
        
        //Get Response
        Http http = new Http();
        HTTPresponse res= http.send(req);
        string response = res.getBody();
        
        parentWrapper pwrapper = (parentWrapper)JSON.deserialize(response,parentWrapper.class);
        
        APTSMD_Apttus_PreSales_Config_Settings2__c preSalesConfig = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        pwrapper.isEnabledInSettings = preSalesConfig.APTSMD_Enable_Email_Limit_Notifications__c;
        pwrapper.SingleEmail.Threshold = (Integer)preSalesConfig.APTSMD_Email_Limit_Notificatn_Threshold__c;
        
        return Json.serialize(pwrapper);
    }
    
    public class parentWrapper
    {
        public SingleEmail singleemail { get; set; }
        public boolean isEnabledInSettings { get;set; }
    }
    public class SingleEmail
    {
        public string Max { get; set; }
        public string Remaining { get; set; }
        public Integer Threshold { get; set; }
    }
    
    public class expirationwrapCls{
        public string name{get;set;}
        public integer interval{get;set;}
        public integer daysRemaining{get;set;}
        public string status{get;set;}
        public datetime expirydate{get;set;}
        public expirationwrapCls(string name, integer interval,integer daysRemaining,string status,datetime expirydate){ 
            this.name=name;
            this.interval=interval;
            this.status=status;
            this.expirydate=expirydate;
            this.daysRemaining=daysRemaining;
        }
    }
}