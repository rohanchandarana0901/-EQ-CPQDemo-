public with sharing class APTSMD_SDOToolsHomepage {

    public User currentUser {get;set;}

    public APTSMD_SDOToolsHomepage() {
        currentUser = [SELECT FirstName, LastName, Name, SmallPhotoUrl, FullPhotoUrl FROM User WHERE Id =: UserInfo.getUserId()];
    }
}