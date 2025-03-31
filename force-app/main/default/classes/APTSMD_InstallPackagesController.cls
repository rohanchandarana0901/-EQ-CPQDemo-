public with sharing class APTSMD_InstallPackagesController{
    public Integer progessCounter {get; set;}
    public Integer installCounter {get; set;}
    public String userNameInput {get; set;}
    public String passwordInput {get; set;}
    public Integer progressBar {get; set;}
    public List<PackageWrapperVF> packageWrapperList {get; set;}
    public List<String> packageList {get; set;}
    public Boolean loggedIn {get; set;}
    public Boolean processComplete {get; set;}
    public Boolean installUnmanagedCode {get; set;}
    public String environmentType {get; set;}
    public String selectedRelease{get;set;}
    public String initialRelease{get;set;}
    public String selectedInstallationType {get; set;}
    public String completeMessage {get; set;}
    public Integer totalItemsForInstallation {get; set;}
    public boolean selectAll {get;set;}    
    public List<PackageWrapperVF> packageWrapperUpdateList {get; set;}
    public List<PackageWrapperVF> allPackageWrappers {get; set;}     
    public ThingsToShow thingsToShow;
    
    private Map<String, String> packageNameNSMap;
    private Map<String, String> packageNamePasswordMap;
    private Map<String, List<String>> packageNameVersionsMap;
    private List<SelectOption> releaseOption;    
    private Map<String,String> packageNameCurrentVersionMap;
    private List<PackageWrapper> pkgExecutionOrder;
    private Map<String,String> pkgNametoNSMap;
    private String prodUserName;
    private String prodPassword;
    private String aosUserName;
    private String aosPassword;
    
    public static final String All='All';
    
    
    public APTSMD_InstallPackagesController(){
        completeMessage = 'Congratulations! Your org setup is complete. Please check Installed Packages to continue.';
        loggedIn = false;
        processComplete = false;
        selectAll=false;
        installUnmanagedCode = false;        
        packageList = new List<String>();
        packageNameVersionsMap = new Map<String, List<String>>();
        packageWrapperList = new List<PackageWrapperVF>();
        allPackageWrappers = new List<PackageWrapperVF>();
        packageWrapperUpdateList = new List<PackageWrapperVF>();
        packageNameCurrentVersionMap=new Map<String,String>();
        packageNameNSMap = new Map<String, String>();
        pkgExecutionOrder=new List<PackageWrapper>();
        pkgNametoNSMap=new Map<String,String>();
        
        thingsToShow=new ThingsToShow();
        releaseOption = new List<SelectOption>(); 
        //releaseOption.add(new SelectOption(All,All));
        GetAndSetCredentials();           
        getAllInfo();
        
        selectedRelease = releaseOption[0].getValue();
        selectedInstallationType = 'Update';
    }
    public void GetAndSetCredentials(){
        Http htp = New Http();
        HttpRequest req = New HttpRequest();
        Map<String, String> valuemap;      

        req.setEndpoint('https://sfmdokeyvault.azurewebsites.net/api/KeyVault/getInstanceDetailFromKeyVault?org=Credential');                
        req.setMethod('GET');  
        req.setTimeout(120000);
        HttpResponse res = htp.send(req);
        string jsonRes=JSON.deserializeUntyped(res.getBody())+'';
        
        credentailList creds=(credentailList)JSON.deserialize('{"creds":'+jsonRes+'}', credentailList.class);
        for(Credentials cred:creds.creds){
            if(cred.Type=='MiddleOrg'){
                aosUserName=cred.Username;
                aosPassword=cred.Password;
            }
            if(cred.Type=='ProductionOrg'){
                prodUserName=cred.Username;
                prodPassword=cred.Password;
            }
        }
                    
    }
    public String ReturnAccessToken ()
    {
        Http htp = New Http();
        HttpRequest req = New HttpRequest();
        Map<String, String> valuemap;    

        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        req.SetBody('grant_type=password&client_id=3MVG9uudbyLbNPZOVbe36XMIDV7_8cfZjzHZsNDHQujfEGSJmncUxtt_qMWZWE8CQxs6gQQa73nlvdHBKJFkx&client_secret=A74494B39057BB8EDE575DF014923B6B52F135272BE9AC8E62CED604309B8645&username='+aosUserName+'&password='+aosPassword);
        
        req.setMethod('POST');    
                       
        HttpResponse res = htp.send(req);
        system.debug('=='+res.getBody());
    
        JSONParser parser = JSON.createParser(res.getBody());
        parser.nextToken();
        valuemap = New Map<String, String>();
        while( parser.nextToken() != JSONToken.END_OBJECT)
        {
            String mapkey = parser.getText();
            parser.nextToken();
            String mapvalue = parser.getText();
            valuemap.put(mapkey,mapvalue);
            System.debug('----'+parser.getText());
        }  
        System.debug('----'+valuemap);  
        
        String access_Token = valuemap.get('access_token');
        System.debug('###access_Token:' + access_Token);
        
        return access_Token;

}

public void getAllInfo()
{
    
string access_token=ReturnAccessToken();
if(access_token!=null){
    
            //updated as on 24 April to resolve No subject alternative DNS name matching na82.my.salesforce.com found.
            string endPoint='https://backupbuild.my.salesforce.com/services/apexrest/getPackageInfo/';
            Http h2 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setHeader('Authorization','Bearer ' + access_token);
            req1.setHeader('Content-Type','application/json');
            req1.setHeader('accept','application/json');
            req1.setMethod('GET');
            req1.setEndpoint(endPoint);
            HttpResponse res1 = h2.send(req1);
    
            if(res1.getStatusCode() >= 200 && res1.getStatusCode() < 300){ 
                thingsToShow=(ThingsToShow)JSON.deserialize(res1.getBody().unescapeCsv().remove('\\'),ThingsToShow.class);                
                if(thingsToShow.success){
                    totalItemsForInstallation=thingsToShow.packageList.size();
                    retrieveAllPackageVersions();
                    setVersionToReleaseMap();
                    for(Release releaseInfo:thingsToShow.releaseList){
                        releaseOption.add(new SelectOption(releaseInfo.Name,releaseInfo.Name)); 
                    }
                
                    for(PackageWrapper packageName : thingsToShow.packageList){
                        pkgExecutionOrder.add(packageName);
                        pkgNametoNSMap.put(packageName.NameSpace,packageName.NameSpace);
                    }
                        
                    setInitialValuestoPackageWrapper();
                    setCurrentVersionNo();                    
                }
                else{                   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Failed To load Data From Server.See Logs for More Detail'));
                    System.debug('Error: '+thingsToShow.errorMessage);
                }
                                
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Failed To load Data From Server.See Logs for More Detail'));
        System.debug('HTTP callout failed:'
                + '\nendPoint=' + req1.getEndPoint()
                + '\nstatusCode=' + res1.getStatusCode()
                + '\nstatus=' + res1.getStatus()
                + '\nbody=' + res1.getBody()
                );                
    }
}
}

    private void retrieveAllPackageVersions(){
        try{
            //code commented by vivek as on 15 dec 2022 as LMA migrated to C2 this is not needed.
            //APTSMD_PartnerServices.LoginResult loginResponse = handleLogin(prodUserName,prodPassword, null);
            APTSMD_PartnerServices.Soap service = new APTSMD_PartnerServices.Soap();
            service.SessionHeader = new APTSMD_PartnerServices.SessionHeader_element();
            //service.SessionHeader.sessionId = loginResponse.sessionId;
            //service.endpoint_x = loginResponse.ServerUrl.split('/services')[0] + '/services/Soap/u/31.0';
            
            Map<String,APTSMD_PartnerServicesSobject.sObject_x_PackageVersion> returnMap = new Map<String,APTSMD_PartnerServicesSobject.sObject_x_PackageVersion>();
            APTSMD_PartnerServices.QueryResult_PackageVersion qr = service.queryPackageVersion('Select ID, Package_Name__c, sfLma__Version__c from sfLma__Package_Version__c Where Show_On_Customer_Portal__c = true');
            for(APTSMD_PartnerServicesSobject.sObject_x_PackageVersion pv : qr.records){
                if(packageNameVersionsMap.containsKey(pv.Package_Name)){
                    List<String> currentVersions = packageNameVersionsMap.get(pv.Package_Name);
                    currentVersions.add(pv.sfLma_Version.startsWith('v')?pv.sfLma_Version.substring(1):pv.sfLma_Version);
                    packageNameVersionsMap.put(pv.Package_Name, currentVersions);
                }else{
                    packageNameVersionsMap.put(pv.Package_Name, new List<String>{pv.sfLma_Version.startsWith('v')?pv.sfLma_Version.substring(1):pv.sfLma_Version});
                }
            }
                                  
            for(PackageWrapper pkg : thingsToShow.packageList){
                List<String> packageVersionList = packageNameVersionsMap.get(pkg.Name);
                if(packageVersionList == null){
                    continue;
                }
                packageVersionList.sort();
                List<String> packageVersionListDescSorted = new List<String>();
                for(Integer index = packageVersionList.size(); index > 0; index--){
                    packageVersionListDescSorted.add(packageVersionList[index - 1]);
                }
                pkg.versionList=packageVersionListDescSorted;                
                System.debug('pkg Name'+pkg.Name);
                allPackageWrappers.add(new PackageWrapperVF(pkg.Name,pkg.NameSpace, pkg.Password, packageVersionListDescSorted));               
            }
            
            
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            return;
        }
    }
    
private void setVersionToReleaseMap(){
    for(PackageWrapper pkg:thingsToShow.packageList){
        pkg.releaseToVersionMap=new Map<String,String>();
        for(PkgToRelease pkgToRelease:thingsToShow.pkgToRelease){
            if(pkgToRelease.packageNS==pkg.NameSpace){                
                pkg.releaseToVersionMap.put(pkgToRelease.releaseName,pkgToRelease.versionNo);
            }
        }
    }
}
    
    public void updatePackageWrapperList(){
        packageWrapperList=new List<PackageWrapperVF>();
        if(selectedRelease==null||selectedRelease==''||selectedRelease==All){
            setInitialValuestoPackageWrapper();
        }
        else{            
            fillPackageWrapperList(selectedRelease);
        }
        setCurrentVersiontoPkgWrapper();
    }
    
    
    
    private void fillPackageWrapperList(String releaseName){
        for(PackageWrapper pkg : thingsToShow.packageList){
                List<String> packageVersionList = new List<String>();
                packageVersionList.add(pkg.releaseToVersionMap.get(releaseName));
                packageWrapperList.add(new PackageWrapperVF(pkg.Name, pkg.NameSpace, pkg.Password, packageVersionList));
        }
    }
    
    
    private void setInitialValuestoPackageWrapper(){
        for(PackageWrapperVF pkg:allPackageWrappers){
                packageWrapperList.add(new PackageWrapperVF(pkg.packageName,pkg.packageNS, pkg.packagePassword, pkg.selectedVersion,pkg.currentVersion, pkg.checkIfInstallationRequired(pkg.currentVersion, pkg.selectedVersion),pkg.versionList));
        }
    }
    
    private void setCurrentVersionNo(){
            MetadataService.MetadataPort service = createService();                     
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();       
            MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
            queryLayout.type_x = 'InstalledPackage';
            queries.add(queryLayout);      
            MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 44);
            List<String> packageNames = new List<String>();
            for (MetadataService.FileProperties fProp : fileProperties) {                
                if(pkgNametoNSMap.containsKey(fProp.fullName)){
                 packageNames.add(fProp.fullName);
                }
            }
            List<MetadataService.InstalledPackage> installPackageInfo=new List<MetadataService.InstalledPackage>();
            Boolean loopEnd=false;
            Integer j=0;
            
        if(packageNames.size()>0){
            for(Integer i=0;!loopEnd;i=i+10){
                List<String> pkgToCall=new List<String>();
                for(;(j<i+10&&j<packageNames.size());j++){
                    pkgToCall.add(packageNames.get(j));
                }                          
                for(MetadataService.InstalledPackage pkg:(List<MetadataService.InstalledPackage>)service.readMetadata('InstalledPackage', pkgToCall).getRecords()){
                    installPackageInfo.add(pkg);
                }
                if(j==packageNames.size()){
                    loopEnd=true;
                }
            }
            
            for(MetadataService.InstalledPackage packageInfo:installPackageInfo)
            {
              packageNameCurrentVersionMap.put(packageInfo.fullName,packageInfo.versionNumber);
            
            }
            setCurrentVersiontoPkgWrapper();
        }
            
    }
    
    private void setCurrentVersiontoPkgWrapper(){
        for(PackageWrapperVF pkg:packageWrapperList){
            if(packageNameCurrentVersionMap.containsKey(pkg.packageNS)){
                pkg.currentVersion=packageNameCurrentVersionMap.get(pkg.packageNS);
                pkg.installationRequired = pkg.checkIfInstallationRequired(pkg.currentVersion, pkg.selectedVersion);
                System.debug('pkg '+pkg.packageNS+pkg.packageName);
                pkg.isCurrentVersionAvailable=true;
            }
            else{
                pkg.isCurrentVersionAvailable=false;
            }
        }
    }
    
    public void installOrUpgradePackages()
    {
        System.debug('method:'+loggedIn+processComplete);
        if(selectedInstallationType == 'New'){
            installAllPackages();
        }else if(selectedInstallationType == 'Update'){
            updatePackages();
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please choose the type of installation.'));
        }
        
        if(progessCounter > totalItemsForInstallation){
            processComplete = true;
        }
        
    }
    
    public void installAllPackages()
    {                   
        loggedIn = true;
                
        if(progessCounter == null){
            progessCounter = 1;
        }
        
        if(installCounter == null){
            installCounter = 1;
        }
        
        if(progessCounter <= totalItemsForInstallation){
            if(installCounter == progessCounter){
                if(!retrieveInstalledPackages(packageWrapperList[progessCounter - 1].packageNS)){
                    installSinglePackage(packageWrapperList[progessCounter - 1].packageNS, packageWrapperList[progessCounter - 1].selectedVersion, packageWrapperList[progessCounter - 1].packagePassword);
                }
                installCounter++;
            }
            else if(retrieveInstalledPackages(packageWrapperList[progessCounter - 1].packageNS)){
                progessCounter++;
            }else{
            }
        }
                        
        progressBar = (Integer)(progessCounter - 1) * 100/totalItemsForInstallation;
    }
    
    public PageReference cancel(){
        return new PageReference('/');
    }
    
    public void updatePackages()
    {   completeMessage = 'Congratulations! Your package upgrade is complete. Please check Installed Packages to verify.';
                    
        preparePackageUpdateList();
        
        loggedIn = true;
                                
        if(progesscounter == null){
             progesscounter = 1;
        }

        if(installCounter == null){
            installCounter = 1;
        }
        
        if(progessCounter <= totalItemsForInstallation){  
            if(installCounter==progessCounter){
                if(!retrieveInstalledPackagesForUpdating(packageWrapperUpdateList[progessCounter - 1].packageNS,packageWrapperUpdateList[progessCounter - 1].selectedVersion)){
                    installSinglePackage(packageWrapperUpdateList[progessCounter - 1].packageNS, packageWrapperUpdateList[progessCounter - 1].selectedVersion, packageWrapperUpdateList[progessCounter - 1].packagePassword);
                }                
                installCounter++;
            }          
            else if(retrieveInstalledPackagesForUpdating(packageWrapperUpdateList[progessCounter - 1].packageNS,packageWrapperUpdateList[progessCounter - 1].selectedVersion)){
                progessCounter++;
            }
            else{

            }                        
        }
        System.debug('update package'+'loging'+loggedIn+'progress count'+progessCounter+'total items'+totalItemsForInstallation+'process'+processComplete);
        progressBar = (Integer)(progessCounter - 1) * 100/totalItemsForInstallation;
    }
    
    private void preparePackageUpdateList(){
        if(packageWrapperUpdateList.size() > 0){
            return;
        }
        for(PackageWrapperVF pw : packageWrapperList){
            if(pw.installationRequired){
                packageWrapperUpdateList.add(pw);
            }
        }
        
        totalItemsForInstallation = packageWrapperUpdateList.size();
    }
    
   
    
    private Boolean retrieveInstalledPackages(String checkForPackage) {
        MetadataService.MetadataPort service = createService();
        Set<String> installPackagesSet = new Set<String>();
        try {
            MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
            query.type_x = 'InstalledPackage';
            double asOfVersion = 44.0;
            MetadataService.FileProperties[] packages = service.listMetadata(new MetadataService.ListMetadataQuery[] {query}, asOfVersion);
            if (packages != null) {
                for (MetadataService.FileProperties pName : packages) {
                    installPackagesSet.add(pName.fullName);
                }
            }
        } catch (TypeException te) {
            ApexPages.addMessages(te); 
        }
        
        return installPackagesSet.contains(checkForPackage);
    }

    private Boolean retrieveInstalledPackagesForUpdating( String checkForPackage,String checkForVersion) {
        MetadataService.MetadataPort service = createService();        
        List<String> pkgToCall=new List<String>();    
        pkgToCall.add(checkForPackage);    
        try {
            MetadataService.InstalledPackage pkg=(MetadataService.InstalledPackage)service.readMetadata('InstalledPackage', pkgToCall).getRecords()[0];
            System.debug('pkg'+pkg);
                    if(pkg!=null){
                        System.debug('pkg'+pkg.versionNumber+' '+checkForVersion);
                     return checkForVersion==pkg.versionNumber;   
                    }                                      
                
        } catch (TypeException te) {
            ApexPages.addMessages(te); 
            System.debug('exception');
        }
        
        return false;
    }

    @future(callout=true)
    private static void installSinglePackage(String packageName, String packageVersion, String packagePassword){
        MetadataService.InstalledPackage installedPackage = new MetadataService.InstalledPackage();        
        installedPackage.password = packagePassword;
        installedPackage.versionNumber = packageVersion;
        installedPackage.fullName = packageName;      

        // Install the package
        MetadataService.MetadataPort service = createService();        
        
        try {
            List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { installedPackage });
            handleSaveResults(results[0]);
        }catch(Exception e) 
        {
           system.debug(e.getMessage());
        }
    }
    
    private static void sendErrorNotification(String errorMessage){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
         
        email.setToAddresses(new string[] {UserInfo.getUserEmail()});
        email.setSubject('One-Click Installer : Package Installation Error');
         
        email.setHtmlBody('Dear ' + UserInfo.getFirstName() + ', <br/><br/>' + errorMessage + '<br/><br/>Please reach out to Conga Lab for further assistance.<br/><br/>Regards,<br/> Conga Lab');
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(Exception exp){
            System.debug(exp.getMessage());
        }
    }
    
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success){
            System.debug('Successfully Installed!');
            return;
        }
            
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                System.debug(String.join(messages, ' '));
            
        }
        if(!saveResult.success){
            System.debug('Request failed with no specified error.');
            sendErrorNotification('An error has occurred while processing the component:' + saveResult.fullName + '<br/>' + saveResult.errors[0]);
        }
    }
    
    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();      
        return service;
    }
    
    
    
    private APTSMD_PartnerServices.LoginResult handleLogin(String userName, String password, String endpoint){
        APTSMD_PartnerServices.Soap service = new APTSMD_PartnerServices.Soap();
        if(endpoint != null){
            service.endpoint_x = endpoint;
        }
        
        try {
            return service.login(userName, password);
        }catch(Exception e) 
        {
           throw e;
        }
    }
            
    public List<SelectOption> getInstallationType() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('New','Setup New Org')); 
        options.add(new SelectOption('Update','Update Existing Packages')); 
        
        return options; 
    }
    
    public List<SelectOption> getreleaseList(){
        return releaseOption;
    }

    public class SortingPurpose{
        public Integer firstNumber;
        public Integer index;
        public String versionNo;

        public SortingPurpose(Integer ind,Integer fNo,String version){
            firstNumber=fNo;
            index=ind;
            versionNo=version;
        }
    }
    
    public class PackageWrapperVF{
        public String packageName {get; set;}
        public String packageNS {get; set;}
        public String packagePassword {get; set;}
        public String selectedVersion {get; set;}
        public String currentVersion {get; set;}
        public List<SelectOption> availableVersions {get; set;}
        public List<String> versionList{get;set;}
        public Boolean installationRequired {get; set;}
        public Boolean isCurrentVersionAvailable{get;set;}

        
        public PackageWrapperVF(String packageName, String packageNS, String packagePassword, List<String> versionNumberList){            
            availableVersions = new List<SelectOption>();
            versionList=new List<String>();
            this.packageName = packageName;
            this.packageNS = packageNS;
            this.packagePassword = packagePassword;
            this.installationRequired=true;
            if(versionNumberList.size()>0){
                for(String vNum : sortVersionList(versionNumberList)){
                    if(vNum!=null){
                        availableVersions.add(new SelectOption(createVersionNumber(vNum),vNum));
                        versionList.add(vNum);                                           
                    }
                }
            }
            this.selectedVersion = versionList[0];
            this.installationRequired = checkIfInstallationRequired(this.currentVersion, this.selectedVersion);
            
        }      
        public List<String> sortVersionList(List<String> versionNumberList){            
            List<SortingPurpose> sPurpose=new List<SortingPurpose>();
            List<String> sortedString=new List<String>();
            List<SortingPurpose> split2=new List<SortingPurpose>();            
            for(String vNum:versionNumberList){
                if(vNum == null){
                    return new list<String>{'Not Available'};
                }
                
                if(vNum.split('\\.').size()>1){
                    sPurpose.add(new SortingPurpose(versionNumberList.indexOf(vNum),Integer.valueOf(vNum.split('\\.')[0]),vNum)); 
                }                
            }
            
            for(Integer i=sPurpose.size()-1;i>=0;i--){
                if(sPurpose[i].firstNumber>sPurpose[0].firstNumber){
                    split2.add(sPurpose[i]);
                    sPurpose.remove(i);
                }
            }

            for(Integer i=split2.size()-1;i>=0;i--){
                sortedString.add(split2[i].versionNo);
            }   
            for(SortingPurpose sp:sPurpose){
                sortedString.add(sp.versionNo);
            }
            return sortedString;
        }
        
        public Boolean checkIfInstallationRequired(String currentVersion, String selectedVersion){
            if(selectedVersion == null || selectedVersion == 'Not Available'){
                return false;
            }
            
            if(currentVersion == null || currentVersion == 'Not Installed'){
                return true;
            }
            
            if(currentVersion.equals(createVersionNumber(selectedVersion))){
                return false;
            }
            
            List<String> currentVersionComponents = currentVersion.split('\\.');
            List<String> selectedVersionComponents = createVersionNumber(selectedVersion).split('\\.');
            
            if(Integer.valueOf(currentVersionComponents[0]) > Integer.valueOf(selectedVersionComponents[0])){
                return false;
            }else if(Integer.valueOf(currentVersionComponents[0]) < Integer.valueOf(selectedVersionComponents[0])){
                return true;
            }
            
            if(Integer.valueOf(currentVersionComponents[1]) > Integer.valueOf(selectedVersionComponents[1])){
                return false;
            }else if(Integer.valueOf(currentVersionComponents[1]) < Integer.valueOf(selectedVersionComponents[1])){
                return true;
            }
            
            if(currentVersionComponents.size() == 3 && selectedVersionComponents.size() == 3
                && Integer.valueOf(currentVersionComponents[2]) < Integer.valueOf(selectedVersionComponents[2])){
                        return true;
            }else if(currentVersionComponents.size() == 2 && selectedVersionComponents.size() == 3){
                        return true;
            }else if(currentVersionComponents.size() == 3 && selectedVersionComponents.size() == 2){
                        return false;
            }
            
            return false;
        }
        
        public PackageWrapperVF(String pkgName,String pkgNS,String pkgPassword,String selectedVer,String currVer,Boolean installreq, List<String> versionNumberList){
            availableVersions = new List<SelectOption>();
            versionList=new List<String>();
            this.packageName=pkgName;
            this.packageNS=pkgNS;
            this.packagePassword=pkgPassword;
            this.selectedVersion=selectedVer;
            this.currentVersion=currVer;
            this.installationRequired=installreq;
            if(versionNumberList.size()>0){
                for(String vNum : versionNumberList){        
                    if(vNum!=null){
                        availableVersions.add(new SelectOption(createVersionNumber(vNum),vNum));
                        versionList.add(vNum);                                           
                    }                                
                }
            } 
        }
        
        private String createVersionNumber(String vNum){     
            if(vNum == 'Not Available'){
                return vNum;
            }
            
            String[] versionElements = vNum.split(' ')[0].split('\\.');
            if(versionElements.size()>0&&versionElements[1]!=null&&versionElements[1].length() == 1&&versionElements.size()==3){
                try{
                    return versionElements[0] + '.' + String.valueOf(Integer.valueOf(versionElements[2]));
                }
                catch(Exception e){
                    return versionElements[0]+'.0';
                }
                
            }else if(versionElements.size()>0&&versionElements[1]!=null&&versionElements[1].length() == 1&&versionElements.size()==4){
                try{
                    return versionElements[0] + '.' + String.valueOf(Integer.valueOf(versionElements[2])) + '.' + String.valueOf(Integer.valueOf(versionElements[3]));
                }
                catch(Exception e){
                    return versionElements[0]+'.0';
                }   
            }
            return vNum;
        }
        
    }
    
    public class credentailList{
        List<Credentials> creds;
    }
    
    public class Credentials{
        public string Type;
        public string Username;
        public string Password;
    }
    

    public class ThingsToShow{
        public List<PkgToRelease> pkgToRelease;                
        public List<PackageWrapper> packageList;  
        public List<Release> releaseList;     
        public Boolean success; 
        public String errorMessage;
    }    
    public class PackageWrapper{
        public String Name {get; set;}
        public String NameSpace {get; set;}
        public String Password {get; set;} 
        public List<String> versionList{get;set;}   
        public Map<String,String> releaseToVersionMap{get;set;} 
    }
    public class PkgToRelease{
        public String releaseName{get;set;}
        public String packageNS{get;set;}
        public String versionNo{get;set;}
    }
    public class Release{
        public String Name{get;set;}
    }
        
}