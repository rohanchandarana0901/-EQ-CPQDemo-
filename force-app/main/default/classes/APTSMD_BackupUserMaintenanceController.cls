/*
 * Usage: This class is used to update the email id and user name of Back User named 'Backup Admin'
 * Author: Chetan Patel    
*/
public class APTSMD_BackupUserMaintenanceController{
    Public static final String APTTUSEMAILID = 'apttusdemo@apttus.com';
    public static final String DEFAULTPASSWORD = '@pttus123'; // if custom setting value is null use this password
     @future
     public static void setBackupAdminUser(){
            System.debug('backup admin user');
            String mainUserName = UserInfo.getUserName();
            String[] temp = mainUserName.split('@');
            String orgId = [select id from organization].id;
            orgId = orgId.substring(0,15);
            List<User> lstBackupUser = [SELECT id,Username,FirstName,LastName,Email FROM User WHERE FirstName='Backup' and LastName='Admin' AND IsActive=TRUE];
            User backupUser;
            
            // Retrieve the password from Presales Custom Settings
            String password = '';
            APTSMD_Apttus_PreSales_Config_Settings2__c config = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
            if(config != null && !String.isBlank(config.APTSMD_BackupUserPassword__c)){
                password = config.APTSMD_BackupUserPassword__c;
            }else{
                password = DEFAULTPASSWORD;
            }
            
            if(!lstBackupUser.isEmpty()){
                System.debug('Coconut1');
                backupUser = lstBackupUser.get(0);
                backupUser.Email = APTTUSEMAILID;
                
                // to reolve the error of Invalid Country value
                //backupUser.CountryCode='US';
                backupUser.Country='United States';
                
                backupUser.Username = 'mdobackupadmin.'+orgId+'@apttusdemo.com'; // backup admin username should be appended with orgid to main user's user name.
                update backupUser; 
                System.debug('Email Id and Username is updated for backup user. Kindly verify the email change by clicking the link sent on '+APTTUSEMAILID);
                try{
                    System.setPassword(backupUser.Id, password);
                }Catch(Exception e){
                    System.debug('>>>> Exception : '+e.getMessage());
                }
            }else{
                System.debug('Coconut2');
                List<Profile> adminProfile = [SELECT id,name from profile where name='System Administrator'];
                
                //create new user 
                backupUser = new User();
                backupUser.FirstName = 'Backup';
                backupUser.LastName = 'Admin';
                backupUser.Alias = 'badmin';
                backupUser.isActive = TRUE;
                backupUser.ProfileId = adminProfile[0].Id;
                backupUser.Email = APTTUSEMAILID;
                backupUser.Username = 'mdobackupadmin.'+ orgId+'@apttusdemo.com';
                backupUser.TimeZoneSidKey = 'America/Los_Angeles';
                backupUser.LocaleSidKey = 'en_US';
                backupUser.EmailEncodingKey = 'ISO-8859-1';
                backupUser.LanguageLocaleKey = 'en_US';
                try{
                    insert backupUser;
                    System.setPassword(backupUser.Id, password);
                    System.debug('New Backup User is created.');
                
                }Catch(Exception e){
                    System.debug('>>>> Exception : '+e.getMessage());
                }   
            }
        
        assignPermissionSet();
    }
        
    private static void assignPermissionSet(){
        User backupUser = [SELECT id,Username,FirstName,LastName,Email FROM User WHERE FirstName='Backup' and LastName='Admin' AND IsActive=TRUE];
        PermissionSet ps = [select id,name from permissionset where name='APTSMD_Password_Never_Expire' limit 1];
                                     
        if(ps!=null){
            Set<Id> userIdSet = new Set<Id>();
            for(PermissionSetAssignment psa : [Select Id, AssigneeId From PermissionSetAssignment Where PermissionSetId = :ps.Id]){
                userIdSet.add(psa.AssigneeId);
            }
            
            List<PermissionSetAssignment> psAssignmentList = new List<PermissionSetAssignment>();
            
            if(!userIdSet.contains(backupUser.id)){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.PermissionSetId = ps.id;
                psa.AssigneeId = backupUser.id;
                psAssignmentList.add(psa);
            }
            
            if(!userIdSet.contains(UserInfo.getUserId())){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.PermissionSetId = ps.id;
                psa.AssigneeId = UserInfo.getUserId();
                psAssignmentList.add(psa);
            }
            
            if(!psAssignmentList.isEmpty()){
                insert psAssignmentList;
            }
        }
    }
    
    public static void createPrimaryUserField()
    {
        update new User(Id = UserInfo.getUserId(), APTSMD_PrimaryUser__c = true);
    }
}