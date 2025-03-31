trigger APTSMD_UsernameChangeNotification on User (after update){
    for(user newuserInfo : trigger.new){
        user olduserInfo = trigger.oldMap.get(newuserInfo.Id);
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0,15);
        if(newuserInfo.username!=olduserInfo.username && (newuserInfo.APTSMD_PrimaryUser__c==true || (newuserInfo.Alias == 'badmin' && newuserInfo.username!='mdobackupadmin.'+orgId+'@apttusdemo.com'))){
            APTSMD_UsernameChangeNotificationHandler.sendEmailToApttusLab(olduserInfo.username,newuserInfo.username,orgId);   
        }   
    }
}