public class APTSMD_ContentSearch {
	@AuraEnabled
    public static List<string> getRecordTypes(){
   		List<string> lstRecordType = new List<String>();
        
        RecordType[] records = [SELECT Id,
                             		Name 
                             FROM RecordType
                             WHERE SobjectType='Apttus__APTS_Agreement__c'];
		if(records !=null && !records.isEmpty()) {
    		for(RecordType record: records) {
        		lstRecordType.add(record.Name);
    		}
		}
    	return lstRecordType;
    }
    
    @AuraEnabled
    public static List<string> getAccounts(){
       List<string> lstAccount = new List<String>();
        
        Account[] records = [SELECT Id, Name FROM Account];
		if(records !=null && !records.isEmpty()) {
    		for(Account record: records) {
        		lstAccount.add(record.Name);
    		}
		}
    	return lstAccount;
    }
}