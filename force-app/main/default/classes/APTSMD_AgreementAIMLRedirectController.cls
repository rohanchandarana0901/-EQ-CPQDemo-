public class APTSMD_AgreementAIMLRedirectController {


    public pagereference init(){
        
        Schema.DescribeSObjectResult r = Apttus__IDEMapProjectRecordType__c.sObjectType.getDescribe();
        string keyPrefix = r.getKeyPrefix();
        return new pagereference('/' + keyPrefix);
        
    }
}