public class APTSMD_CongaGlobalSolutionsCtrl {

    @AuraEnabled
    public static String getPerformanceReportLink(){
        String performanceReportLink = [SELECT APTSMD_Performance_Report_Link__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].APTSMD_Performance_Report_Link__c;
        return performanceReportLink + '&DisableRowNums=1&DS7=3&BML=Generating Performance Report';
    }
    
    @AuraEnabled
    public static String getQbrLink(){
        String qbrLink = [SELECT APTSMD_QBR_Link__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].APTSMD_QBR_Link__c;
        return qbrLink + '&OFN=QBR+For_' + UserInfo.getFirstName() + '_' + UserInfo.getLastName() + '_' + Date.newInstance(Date.today().year(),Date.today().month(),Date.today().day()) + '&DisableRowNums=1&OCNR=1&DS7=3&BML=Downloading+QBR';
    }
    
    @AuraEnabled
    public static String getCaseBreakdownLink(){
        String caseBreakdownLink = [SELECT APTSMD_Case_Breakdown_Link__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].APTSMD_Case_Breakdown_Link__c;
        return caseBreakdownLink + '&OFN=Case+Breakdown' + '_' + Date.newInstance(Date.today().year(),Date.today().month(),Date.today().day()) + '&DS7=3&BML=Creating Case Breakdown';
    }
 }