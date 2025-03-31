///This class is useful to assign licenses and permission set to demo user enabled with MFA
///Created by: Vivek Parmar
///Created on: 30 Nov 2021
///Updated on: 29 Jan 2022
public class APTSMD_DemoUserHelperCtrl {
    public static string DEMO_USER_PASSWORD = 'cong@123';
    public List<User> demoUsers {get;set;}
    public Set<Id> userIds {get;set;}
    public MFAResponse resp {get;set;}
    public string respJSON {get;set;}   
    public static String orgId {get;set;}
    
    public APTSMD_DemoUserHelperCtrl() {
        
        demoUsers = [Select Id,Name from User where APTSMD_Is_MFA_Demo_User__c = true];
        System.debug(demoUsers);
        userIds = new Set<Id>();
        for(User demoUser:demoUsers){
            userIds.add(demoUser.Id);
        }
        
        resp = new MFAResponse();
        resp.users = new List<User>();
        orgId = [select id from organization].id;
        orgId = orgId.substring(0,15).toLowerCase();
    }
    
    public void createDemoUser(Integer nextIndex, Integer count){
        List<User> demoUsersNew = new List<User>();
        List<Profile> adminProfile = [SELECT id,name from profile where name='System Administrator'];
        String roleId = [select id from UserRole where name = 'CEO'].id;
        
        nextIndex = nextIndex > 1 ? nextIndex : 1;
        if(nextIndex ==1 ){
            count = 3;//by default if there are no demo user then create 2 demo users
        }
        else{
            count = count > 0 ? nextIndex+count: 3;
        }
        
        system.debug('count -'+count);
        system.debug('nextIndex -'+nextIndex);
        
        for(Integer i=nextIndex; i< count; i++){
            User demoUser1 = new User();
            demoUser1.FirstName='Demo';
            demoUser1.LastName='User'+i;
            demoUser1.Alias='duser'+i;
            demoUser1.isActive=TRUE;
            demoUser1.ProfileId=adminProfile[0].Id;
            demoUser1.Email='congademo@conga.com';
            demoUser1.Username='demouser'+i+'.'+orgId+'@congademo.com';
            demoUser1.TimeZoneSidKey='America/Los_Angeles';
            demoUser1.LocaleSidKey='en_US';
            demoUser1.EmailEncodingKey='ISO-8859-1';
            demoUser1.LanguageLocaleKey='en_US';
            demoUser1.UserRoleId =roleId;
            demoUser1.APTSMD_Is_MFA_Demo_User__c = true;
            demoUsersNew.add(demoUser1);
        }
        system.debug('demoUsersNew -'+demoUsersNew);
        insert demoUsersNew;
        system.debug('inserted users -');
        demoUsersNew = [Select Id,Name from User where APTSMD_Is_MFA_Demo_User__c = true];
        system.debug('demoUsersNew  -'+demoUsersNew);
    }
    public void createUpdateDemoUserDetail(){
        demoUsers = [Select Id,Name from User where APTSMD_Is_MFA_Demo_User__c = true];
        if(demoUsers.isEmpty()){
            try{
                createDemoUser(1,3);//start with index 1 and we want 2 user so passing 3 value (our loop start with 1 not 0 so)
                updateDemoUserDetail();
            }
            catch(Exception ex){
                system.debug('create user failed -'+ex);
                throw ex;
            }
        }
        else {
            updateDemoUserDetail();
        }
        
    }
    public void updateDemoUserDetail(){
        demoUsers = [Select Id,Name from User where APTSMD_Is_MFA_Demo_User__c = true];
        
        if(!demoUsers.isEmpty()){
            String orgId = [select id from organization].id;
            orgId = orgId.substring(0,15).toLowerCase();
            for(User demoUser:demoUsers){
                string username = demoUser.name.toLowerCase().replace(' ', '');
                demoUser.Username = username +'.'+orgId +'@congademo.com'; 
                if(!userIds.contains(demoUser.Id)){
                    userIds.add(demoUser.Id);
                }
                resp.users.add(demoUser);
            }
            update demoUsers;
            System.debug('Demo Username Updated');
            
            resp.isUsernameUpdated = true;
            for(User demoUser:demoUsers){
                try{
                    System.setPassword(demoUser.Id, DEMO_USER_PASSWORD);
                    resp.isPwdUpdated = true;
                }Catch(Exception e){
                    System.debug('Error Occured while setting demo user password : '+e.getMessage());
                    if(e.getMessage().contains('UNKNOWN_EXCEPTION: invalid repeated password')){
                        resp.isPwdUpdated = true;
                    }
                }
            }
            
            assignPS(userIds);
            assignLS(userIds);
        }
    }
    
    public void assignPS(Set<Id> userIds){
        List<PermissionSet> ps = [select id,name from permissionset where name='APTSMD_Password_Never_Expire' or
                           name = 'Intelligent_Import_Admin_UI' or
                           name = 'ActionGrid_Users' or
                           name = 'APTS_Agreement_Type_AIML_Admin' or
                           name = 'APTSMD_MFA'];
        system.debug('ps=='+ps.size());
        List<PermissionSetAssignment> psAssignmentList = new List<PermissionSetAssignment>();
        for(Id u:userIds){
            for(PermissionSet p: ps){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.PermissionSetId = p.id;
                psa.AssigneeId = u;
                psAssignmentList.add(psa);
            }
        }
        try{
            if(!psAssignmentList.isEmpty()){
                Database.UpsertResult[] psUpsertResult = Database.upsert(psAssignmentList,false); 
                resp.psUpsertResult = psUpsertResult;
                resp.isPSAssigned = true;
                for(Database.UpsertResult p:psUpsertResult){
                    for(Database.Error result:p.getErrors()) {
                        if (result.getStatusCode() != StatusCode.DUPLICATE_VALUE){
                            resp.isPSAssigned = false;
                        }
                    }
                }
            }
		}
        
        catch(Exception ex){
            System.debug('Error Occured while assigning PS '+ex.getMessage());
        }
    }
    
    public void assignLS(Set<Id> userIds){
        List<UserPackageLicense> existingList = [Select Id, UserId, PackageLicenseId from UserPackageLicense
                                                	Where UserId in :userIds];
        List<UserPackageLicense> uplList = new List<UserPackageLicense>();
        List<PackageLicense> pl = [SELECT Id,NamespacePrefix,AllowedLicenses,ExpirationDate,UsedLicenses  FROM PackageLicense WHERE 
                                    (NamespacePrefix like '%conga%' or NamespacePrefix like '%apttus%' or NamespacePrefix='CRMC_PP' or 
                                    NamespacePrefix='cnga' or NamespacePrefix='echosign_dev1' or NamespacePrefix='FSTR') 
                                  	AND  NamespacePrefix != 'Apttus_B2BStore' AND NamespacePrefix != 'Apttus_XGApps'];
        system.debug('pl=='+pl.size());
        for(Id u:userIds){
            
            for(PackageLicense p :pl){
                for(UserPackageLicense userPackageLicense : existingList){
                    if(userPackageLicense.UserId == u && userPackageLicense.PackageLicenseId == p.Id
                      	&& p.AllowedLicenses > p.UsedLicenses){
                        continue;
                    }
                }
                UserPackageLicense upl = new UserPackageLicense();
                upl.UserId= u;
                upl.PackageLicenseId = p.Id;
                uplList.add(upl);
            }
        }
        system.debug('uplList='+uplList);
        try{
            if(!uplList.isEmpty()){
                Database.UpsertResult[] lsLicenseResult = Database.upsert(uplList,false); 
                resp.lsUpsertResult = lsLicenseResult;
                resp.isLSAssigned = true;
                for(Database.UpsertResult l:lsLicenseResult){
                    for(Database.Error result:l.getErrors()) {
                        if (result.getStatusCode() != StatusCode.DUPLICATE_VALUE){
                            resp.isLSAssigned = false;
                        }
                    }
                }
            }
		}
        catch(Exception ex){
            System.debug('Error Occured while assigning LS '+ex.getMessage());
        }
        system.debug('@@resp'+resp);
        respJSON = JSON.serialize(resp);
    }
	
    @RemoteAction
    public static String createAdditionalDemoUser(Integer count) {
        try{
            APTSMD_DemoUserHelperCtrl obj = new APTSMD_DemoUserHelperCtrl();
            List<User> demoUsers = [Select Id,Name from User where APTSMD_Is_MFA_Demo_User__c = true];
            System.debug('createAdditionalDemoUser demoUsers size='+demoUsers.size());
            integer nextIndex = demoUsers.size()+1;
            obj.createDemoUser(nextIndex,count);
            obj.updateDemoUserDetail();
            return 'Success';
        }
        catch(Exception ex){
            system.debug('createAdditionalDemoUser failed -'+ex);
            return ex.getMessage();
        }
    }
    
    
    public Boolean autoAssigLicense(){
        try{
             //before showing MFA demo user creation, first check adequate license count
            List<PackageLicense> packageLicenseList=[SELECT Id,CreatedDate,ExpirationDate,NamespacePrefix,Status,AllowedLicenses,UsedLicenses   
                    FROM PackageLicense WHERE 
                    (NamespacePrefix like 'Apttus%' OR NamespacePrefix in 
                    ('APXT_CongaSign', 'APXTConga4', 'CRMC_PP', 'FSTR', 'APXT_Redlining')) 
                    AND NamespacePrefix != 'Apttus_XAAdmin' AND  NamespacePrefix != 'Apttus_B2BStore' AND NamespacePrefix != 'Apttus_XGApps' 
                    AND AllowedLicenses > 0 Order By NamespacePrefix];//
            system.debug('packageLicenseList');
            Boolean isAdequateLicense = true;
            for(PackageLicense pkg:packageLicenseList){
                if(!((pkg.AllowedLicenses - pkg.UsedLicenses) > 2 )){
                    isAdequateLicense = false;
                    break;
                }  
            }
            system.debug('isAdequateLicense='+isAdequateLicense);
            
            APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        
            system.debug('Is MFA Demo Persona Updated?='+presalesConfigSetting.APTSMD_Is_MFA_Demo_Persona_Updated__c);
            if(isAdequateLicense && !presalesConfigSetting.APTSMD_Is_MFA_Demo_Persona_Updated__c){ 
                
                system.debug('userIds='+userIds);
                assignLS(userIds);
                system.debug('completed updateDemoUserDetail()=');
                updateCustomSettingMFAFlag();
                system.debug('updated flag APTSMD_Is_MFA_Demo_Persona_Updated__c');
                return true;
            }
            return false;
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            return false;
        }
    }
    
    @future
    public static void updateCustomSettingMFAFlag(){
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        presalesConfigSetting.APTSMD_Is_MFA_Demo_Persona_Updated__c = true;
        update presalesConfigSetting;
    }
    
    public class MFAResponse{
        public List<User> users {get;set;}
        public Boolean isUsernameUpdated {get;set;}
        public Boolean isPwdUpdated {get;set;}
        public Boolean isPSAssigned {get;set;}
        public Boolean isLSAssigned {get;set;}
        public Database.UpsertResult[] psUpsertResult {get;set;}
        public Database.UpsertResult[] lsUpsertResult {get;set;}
    }
}