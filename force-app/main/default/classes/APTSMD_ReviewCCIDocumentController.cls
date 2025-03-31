//origional authour - Nasir M
//created on - 13 June 2024
//modified by - Vivek P 
//modified on - 17 June 2024
//purpose - to open the CCI extracted document screen direct from salesforce

public class APTSMD_ReviewCCIDocumentController {
    
    public String agreementRecordId {get;set;}
    public String agreementExternalRecordId {get;set;}
         
    public APTSMD_ReviewCCIDocumentController (){
        agreementRecordId = Apexpages.currentPage().getParameters().get('id');
        agreementExternalRecordId = Apexpages.currentPage().getParameters().get('externalid');
    }
    
    public PageReference getRLPDocumentId(){
        String endpoint = APTSMD_DocumentServices.documentServiceMetadata.APTSMD_Conga_Platform_Base_URL__c + '/api/data/v1/objects/ImportedDocument?criteria=AgreementId%3D%27' + agreementExternalRecordId + '%27';
        System.debug(endpoint);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');

        String token = APTSMD_DocumentServices.getCongaPlatformUserSpecificAuthToken();
        
        req.setHeader('Authorization', 'Bearer '+token );
        req.setHeader('user-id', APTSMD_DocumentServices.documentServiceMetadata.APTSMD_Conga_Platform_Admin_User_ID__c);
        req.setMethod('GET');
        
        Http http = new Http();
        String rlpDocumentId = null;
        try{
            HTTPResponse response = http.send(req);
            System.debug(response.getBody());
            
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() != JSONToken.START_OBJECT
                    && parser.nextToken() == JSONToken.FIELD_NAME
                    && parser.getText() == 'DocumentId') {
                    parser.nextToken();
                    rlpDocumentId = parser.getText();                    
                    system.debug('###Id: ' + rlpDocumentId);
                }
            }
        }
        catch(Exception ex){
            System.debug(ex);
        }
        
        return new PageReference(APTSMD_DocumentServices.documentServiceMetadata.APTSMD_Conga_Platform_Base_URL__c + '/cci/user/review/?documentId=' + rlpDocumentId + '&agreementId=' + agreementExternalRecordId);
    }

}