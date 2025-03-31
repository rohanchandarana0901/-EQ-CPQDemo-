public without sharing class APTSMD_ConsentFormController {
    
    // processConsentForm - This method process consent data and generate the consent 
    @AuraEnabled
    public static Response processConsentForm(String fullName, String companyName, String address, String phoneNumber, String emailAddress, Date serviceStartDate, Date serviceEndDate, Boolean consentStatement) {
        try {

            APTSMD_Presales_Config_Metadata__mdt documentServiceMetadata = APTSMD_Presales_Config_Metadata__mdt.getInstance('Default');

            // Process Information
            ConsentFormData consentFormRecord = new ConsentFormData();
            consentFormRecord.fullName = fullName;
            consentFormRecord.companyName = companyName;
            consentFormRecord.address = address;
            consentFormRecord.phoneNumber = phoneNumber;
            consentFormRecord.emailAddress = emailAddress;
            consentFormRecord.serviceStartDate = serviceStartDate;
            consentFormRecord.serviceEndDate = serviceEndDate;
            consentFormRecord.consentStatement = consentStatement;
            consentFormRecord.eSignTag = '{{esl:Signer1:capture:size(200,50)}}';
            consentFormRecord.eSignDateTag = '{{esl:Signer1:SigningDate}}';

            // Get Consent Form Template Data
            APXTConga4__Conga_Template__c consentTemplate = new APXTConga4__Conga_Template__c();
            consentTemplate = [SELECT Id, Name, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = :documentServiceMetadata.APTSMD_Template_Name__c LIMIT 1];

            // Document Name
            String documentName = 'Consent Form for ' + fullName;

            // Get Conga Lab Account to use as master record id
            Account congaLabAccountRecord = new Account();
            congaLabAccountRecord = [SELECT Id, Name FROM Account WHERE Name = 'Conga Lab'];

            // Generate Consent Form
            string generateDocumentResponse = APTSMD_DocumentServices.generateDocument(documentName, JSON.serialize(consentFormRecord), congaLabAccountRecord.Id, consentTemplate.Id);
            // Return response
            return new Response(true, 'Document generation process started successfully! Please check the status periodically.', JSON.deserializeUntyped(generateDocumentResponse));
        } catch (Exception e) {
            //throw new AuraHandledException('Error saving consent form: ' + e.getMessage());
            return new Response(false, 'Erorr: ' + e.getMessage() + ' @ Line#: ' + e.getLineNumber(), null);
        }
    }

    // generateDocument - This method generate document using conga composer apis.
    @AuraEnabled
    public static Response checkDocGenProcessStatus(string correlationId) {
        try {
            // Check for valid correlationId
            if(correlationId == null || correlationId == ''){
                return new Response(false, 'Please make sure you have passed valid correlationId to check the docgen status.',null);
            }
            // Call checkDocGenStatus api
            string docGenStatusResponse = APTSMD_DocumentServices.checkDocGenStatus(correlationId);
            // Return response
            return new Response(true, 'Document Generation status fecthed successfully.', JSON.deserializeUntyped(docGenStatusResponse));
        } catch (Exception e) {
            //throw new AuraHandledException('Error saving consent form: ' + e.getMessage());
            return new Response(false, 'Erorr: ' + e.getMessage() + ' @ Line#: ' + e.getLineNumber(), null);
        }
    }

    // sendDocumentForSign - This method generate document using conga composer apis.
    @AuraEnabled
    public static Response sendDocumentForCongaSign(string correlationId, String fullName, String companyName, String emailAddress) {
        try {
            // Check for valid correlationId
            if(correlationId == null || correlationId == ''){
                return new Response(false, 'Please make sure you have passed valid correlationId to check the docgen status.',null);
            }
            // Call getGeneratedDocURL api
            string getGeneratedDocURLResponse = APTSMD_DocumentServices.getGeneratedDocURL(correlationId);
            Map<String, Object> getGeneratedDocURLJOSNResponse = ((Map<String, Object>)JSON.deserializeUntyped(getGeneratedDocURLResponse));
            system.debug('getGeneratedDocURLJOSNResponse >> '+ getGeneratedDocURLJOSNResponse);
            if(getGeneratedDocURLJOSNResponse.get('isSuccessful').toString() == 'true'){
                // Get generated document url from json object
                String generatedDocURL = ((Map<String, Object>) ((List<Object>) ((Map<String, Object>) getGeneratedDocURLJOSNResponse.get('preSignedCreateResponseModel')).get('fileInfoDetailsList'))[0]).get('url').toString();
                if(generatedDocURL != null && generatedDocURL != ''){
                    // Get generated document
                    HttpResponse generatedDocumentAPIResponse = APTSMD_DocumentServices.getGeneratedDoc(generatedDocURL);
                    if(generatedDocumentAPIResponse.getStatusCode() == 200){
                        // Call sendDocumentForCongaSign API
                        String sendDocumentForCongaSignResponse = APTSMD_DocumentServices.sendDocumentForCongaSign('Consent Form for '+ fullName, fullName.split(' ')[0], (fullName.split(' ').size() > 1 ? fullName.split(' ')[1] : fullName.split(' ')[0]), emailAddress, companyName, generatedDocumentAPIResponse.getBodyAsBlob());
                        // Check for sendDocumentForCongaSignResponse
                        if(sendDocumentForCongaSignResponse.contains('id')){
                            // Return response
                            return new Response(true, 'Document sent for signature successfully.', JSON.deserializeUntyped(sendDocumentForCongaSignResponse));
                        }else{
                            // Return response
                            return new Response(false, 'Error occured while sending the document.', sendDocumentForCongaSignResponse);
                        }
                    }else{
                        // Return response
                        return new Response(false, 'Something went wrong! Unable to fetch the generated document. Please try again later.', null);
                    }
                }else{
                    // Return response
                    return new Response(false, 'Something went wrong! Unable to fetch the generated document url. Please try again later.', null);
                }
            }else{
                // Return response
                return new Response(false, 'Something went wrong! Unable to fetch the generated document url. Please try again later.', null);
            }
        } catch (Exception e) {
            //throw new AuraHandledException('Error saving consent form: ' + e.getMessage());
            return new Response(false, 'Erorr: ' + e.getMessage() + ' @ Line#: ' + e.getLineNumber(), null);
        }
    }

    // generateDocument - This method generate document using conga composer apis.
    @AuraEnabled
    public static Response getSigningURL(string packageId) {
        try {
            // Check for valid correlationId
            if(packageId == null || packageId == ''){
                return new Response(false, 'Please make sure you have passed valid packageId to get signing url.',null);
            }
            // Call checkDocGenStatus api
            string signingURL = APTSMD_DocumentServices.getCongaSignSigningURL(packageId, 'Signer1');
            // Return response
            return new Response(true, 'Signing URL fecthed successfully.', signingURL);
        } catch (Exception e) {
            //throw new AuraHandledException('Error saving consent form: ' + e.getMessage());
            return new Response(false, 'Erorr: ' + e.getMessage() + ' @ Line#: ' + e.getLineNumber(), null);
        }
    }

    // Helper Classes
    public class ConsentFormData {
        @AuraEnabled
        public String fullName;
        @AuraEnabled
        public String companyName;
        @AuraEnabled
        public String address;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public String emailAddress;
        @AuraEnabled
        public Date serviceStartDate;
        @AuraEnabled
        public Date serviceEndDate;
        @AuraEnabled
        public Boolean consentStatement;
        @AuraEnabled
        public String billingCycle;
        @AuraEnabled
        public String eSignTag;
        @AuraEnabled
        public String eSignDateTag;
    }

    public class Response{
        @AuraEnabled
        public boolean isSuccess {get;set;}
        @AuraEnabled
        public string message {get;set;}
        @AuraEnabled
        public object data {get;set;}

        public response(boolean isSuccess, string message, object data){
            this.isSuccess = isSuccess;
            this.message = message;
            this.data = data;
        }
    }

}