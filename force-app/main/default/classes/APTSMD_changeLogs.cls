public with sharing class APTSMD_changeLogs {

    public pageReference goNew(){
        return new PageReference('/' + APTSMD_SDO_Changelog__c.SobjectType.getDescribe().getKeyPrefix() + '/e?');
    }

    public APTSMD_SDO_Changelog__c getNewPost()
    {
        List<APTSMD_SDO_Changelog__c> npList = [select id, name, lastmodifieddate, createdDate, APTSMD_body__c from APTSMD_SDO_Changelog__c order by APTSMD_changelog_number__c desc limit 1];
        if(npList.size() > 0)
            return npList[0];
        else
            return new APTSMD_SDO_Changelog__c();
    }

    public List<APTSMD_SDO_Changelog__c> getAllPosts(){
        return [select id, name, lastmodifieddate, createdDate, APTSMD_body__c from APTSMD_SDO_Changelog__c order by APTSMD_changelog_number__c desc];
    }

    public static testMethod void testMe(){
        APTSMD_changeLogs cl = new APTSMD_changeLogs();
        cl.goNew();
        cl.getAllPosts();
        cl.getNewPost();
    }

}