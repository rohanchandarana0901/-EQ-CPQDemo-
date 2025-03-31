public class APTSMD_DownloadAgreementDoc {
    private Document docId;
    public string docDwnloadPage{get;set;}
    public string goBackToHomePage{get;set;}
    public APTSMD_DownloadAgreementDoc(){
        docId = [SELECT id FROM Document WHERE Name='Intelliegent Import Sample Document' LIMIT 1];
        docDwnloadPage = System.URL.getSalesforceBaseURL().toString()+'/servlet/servlet.FileDownload?file='+docId.id;
        goBackToHomePage = System.URL.getSalesforceBaseURL().toString()+'/home/home.jsp';
    }
}