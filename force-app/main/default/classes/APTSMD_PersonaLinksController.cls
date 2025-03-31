public class APTSMD_PersonaLinksController {
    @AuraEnabled 
    public static Map<String, String> getUserDetails(){
        List<User> userList = [Select Id, Name from User 
                               				Where Name in ('Mary Manager', 'Larry Legal', 'Francis Finance', 'Paula Pricing', 'Sally Sales', 'VP Sales')];
        Map<String, String> options = new Map<String, String>();
		
        for (User user: userList) {
            String redirectionURL = '/servlet/servlet.su?oid=' + UserInfo.getOrganizationId() + '&suorgadminid=' + user.Id;
			redirectionURL += '&retURL=%2Flightning%2Fsetup%2FManageUsers%2Fhome%3FisUserEntityOverride%3D1%26retURL%3D%252Fui%252Fsetup%252FSetup%253Fsetupid%253DUsers%26setupid%3DManageUsers&targetURL=%2Fhome%2Fhome.jsp';
            options.put(redirectionURL, user.Name);
        }
        return options;
    }
}