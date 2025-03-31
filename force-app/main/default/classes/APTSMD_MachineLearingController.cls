public class APTSMD_MachineLearingController {
    
    public static string instanceURL {get;set;}
    
    public string instanceURLtest{get;set;}
    
    public APTSMD_MachineLearingController(){
        instanceURLtest = Url.getOrgDomainUrl().toExternalForm();
    }
    
    public static String Instance {
        get {
            if (Instance == null) {
                String uid = UserInfo.getUserId();
                String sid = UserInfo.getSessionId();
                String oid = UserInfo.getOrganizationId();
                String base = Url.getSalesforceBaseUrl().toExternalForm();
    
                if (sid == null) return base.replaceFirst('http:', 'https:');
    
                PageReference api = new PageReference('/id/' + oid + '/' + uid + '?access_token=' + sid);
                String content = Test.isRunningTest() ? '{"urls":{"profile":"' + base + '"}}' : api.getContent().toString();
                Url profile = new Url(content.substringBetween('"profile":"', '"'));
                Instance = profile.getProtocol() + '://' + profile.getHost();
            }
            return Instance;
        }
    }
    public static void GetBaseUrlForInstance() {
        instanceURL =  Instance;
    
    }
}