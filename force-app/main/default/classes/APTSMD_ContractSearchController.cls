/**
 *  Purpose : This Class is used for content Search Functionality
 *  Author : Chetan Meghnathi , Sagar Pomal
 *  Date : 31st Jan , 2017
**/
public class APTSMD_ContractSearchController {
    public String agreementListJSON {get;set;}
    public String searchText {get;set;}
    public List<recordtype> recordTypeList {get;set;}
    public String recordTypeListJSON {get;set;}
    public List<User> userList {get;set;}
    public String userListJSON {get;set;}
    
     // Currancy Variable initialize
    public boolean isMultiCurrancyOn {get;set;}
    public string defaultCurrancy {get;set;}
    public string dateFormat {get;set;}
    
    public static Map<String,Blob> contentData= new Map<String,Blob>();
    /*
        This constructor will check whether there is any parameter available or not.
    */
    public APTSMD_ContractSearchController(){
         // Set currency information
        this.defaultCurrancy = APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(true,'');  //UserInfo.getDefaultCurrency();
        this.isMultiCurrancyOn = Schema.getGlobalDescribe().containsKey('CurrencyType');
        this.dateFormat =  APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(false,''); 
        String search = apexpages.currentpage().getparameters().get('search');
        if(search != null && search != 'undefined'){
            searchText = search;
        }
        else{
            searchText = '';
        }
        List<AgreementWrapper> agreementList = new List<AgreementWrapper>();
        agreementListJSON = JSON.serialize(agreementList);
        userList = [select firstname, lastname from user];
        userListJSON = JSON.serialize(userList);
        recordTypeList = [select id, name, sobjecttype from recordtype where sobjecttype= 'Apttus__APTS_Agreement__c'];
        recordTypeListJSON = JSON.serialize(recordTypeList);
    }
     
    /*
        This Method will return list of agreements based on Agreement ids passed to it.
    */
    static List<Apttus__APTS_Agreement__c> getAgreements(Set<Id> lstAgreementIds ){
        return [select id,Name,Apttus__Account__r.Name,Apttus__FF_Agreement_Number__c,
                Apttus__Status__c,Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c
                FROM Apttus__APTS_Agreement__c where ID in:lstAgreementIds];
    }

    /*
        This Remote method will return Base64 of PDF file based on content id passed to it.
    */
    @Remoteaction
    public static String getContentVersionBlob(String contentVerId){
        List<ContentVersion> contentVerList = [select id, versiondata from ContentVersion where id =: contentVerId ];
        
        if(!contentVerList.isEmpty()){
            return EncodingUtil.base64Encode(contentVerList[0].versiondata);
        }else{
            return null;
        }

    }
    
    /*
        This Remote method will send an email to provided email id.
        @@ emailID - email id of the recepient
        @@ ContentID - Content Version Id
        @@ emailBody - This is the Searched Result in HTML format
        @@ agreementNumber - Agreement Number
    */
    @RemoteAction
    public static void sendEmail(String emailID,String ContentID,String emailBody,String agreementNumber,string searchText){  
        // Create a list to hold the email addresses
        List<String> toAddresses = new List<String>();
        toAddresses.add(emailID);
        
        // Prepare HTML Body
        String htmlBody = '<style>mark {background: #fff03f;background-color:#fff03f; }caption, td, th {text-align: justify;border-bottom: 1px solid black;}</style>';
        htmlBody +='Hi ,You have searched for <b>\''+ searchText +'\'</b> and <br/>Below is the Searched Result for Agreement #'+agreementNumber+'<br/><br/>'+emailBody;
        htmlBody += '<br/>Thank You,<br /> Team Conga.';
        
        // Create a new email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        // Set the recipient, subject, and HTML body
        email.setToAddresses(toAddresses);
        email.setSubject('Searched result for \''+ searchText +'\' in '+agreementNumber);
        email.setHtmlBody(htmlBody);
        
        // Fetch files and attach it to the email
        List<Messaging.EmailFileAttachment> liAttachment = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion a : [select VersionData, ContentSize,ContentUrl from ContentVersion where ID = :ContentID]){
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setBody(a.VersionData);
            efa.setFileName('Attachment.pdf');
            liAttachment.add(efa);
        }
        email.setFileAttachments(liAttachment);
        
         // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
        
        /*Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { emailID };
        message.optOutPolicy = 'FILTER';
        message.subject = 'Searched result for \''+ searchText +'\' in '+agreementNumber;
        String style= '<style>mark {background: #fff03f;background-color:#fff03f; }caption, td, th {text-align: justify;border-bottom: 1px solid black;}</style>';
        style+='Hi ,You have searched for <b>\''+ searchText +'\'</b> and <br/>Below is the Searched Result for Agreement #'+agreementNumber+'<br/><br/>'+emailBody;
        style+= '<br/>Thank You';
        message.setHtmlBody(style);
        List<Messaging.EmailFileAttachment> liAttachment = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion a : [select VersionData, ContentSize,ContentUrl from ContentVersion where ID = :ContentID])        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setBody(a.VersionData);
            efa.setFileName('Attachment.pdf');
            liAttachment.add(efa);
        }
        message.setFileAttachments(liAttachment);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);*/
    }
    
    //method for getting where
    public static string buildWhereClause(string fieldName, string value){
        String whereQuery = ' And ' + fieldName + ' = \'' + value + '\'';
        return whereQuery;
    }
    
    /*
        This Remote method will search the Agreement documents based on search text we pass to it.
        It will return LIst of the AgrementWrapper.
    */
    @Remoteaction
    public static List<AgreementWrapper> getORSearchAgmt(String seacrhText, String accountName, String agreementType, String ownerName, String activatedDate, String endDateFrom, String endDateTo) {
        List<AgreementWrapper> agreementList = new List<AgreementWrapper>();
        Map<ID, ID> agmtIdDocIdMap = new Map<ID, ID>();
        DateTime agreementLastDate;
        String agreementLastDateString;
        DateTime fromEndDate;
        DateTime toEndDate;
        
        if(endDateFrom != '' && endDateTo != ''){
            fromEndDate = Date.valueOf(endDateFrom.substring(0,10) );
            toEndDate = Date.valueOf(endDateTo.substring(0,10));
        }
        

        String queryForAgreement = '';
        queryForAgreement = 'select id from Apttus__APTS_Agreement__c where id != null ';
        
        if(accountName != NULL && accountName != ''){
            queryForAgreement =queryForAgreement+ ' AND Apttus__Account__r.Name LIKE ' + '\'%' + accountName + '%\'';   
        }
        if(agreementType != NULL && agreementType != '' && agreementType != '--None--'){
            queryForAgreement = queryForAgreement + buildWhereClause('RecordType.Name', agreementType);   
        }
        if(ownerName != NULL && ownerName != '' && ownerName != '--None--'){
            queryForAgreement = queryForAgreement + buildWhereClause('Owner.Name', ownerName);   
        }
        
        if(activatedDate != NULL && activatedDate != '' && agreementType != '--None--'){
            if(activatedDate == 'Last 1 Month'){
                agreementLastDateString = DateTime.now().addMonths(-1).format('yyyy-MM-dd');
            } else if(activatedDate == 'Last 6 Months'){
                agreementLastDateString = DateTime.now().addMonths(-6).format('YYYY-MM-dd');
            } else if(activatedDate == 'Last 1 Year'){
                agreementLastDateString = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
            } else if(activatedDate == 'Last 3 Years'){
                agreementLastDateString = DateTime.now().addMonths(-36).format('yyyy-MM-dd');
            }
        }
        
        if(agreementLastDateString != NULL){
            String todaysDate = DateTime.now().format('yyyy-MM-dd');
            queryForAgreement = queryForAgreement + ' AND Apttus__Activated_Date__c <= ' + todaysDate + ' and Apttus__Activated_Date__c >= ' +  agreementLastDateString;   
        }
        if(fromEndDate != null && toEndDate != null){
            queryForAgreement = queryForAgreement + ' AND Apttus__Contract_End_Date__c >= ' + endDateFrom.substring(0,10) + ' and Apttus__Contract_End_Date__c <= ' + endDateTo.substring(0,10);
        }
        
        System.debug('queryForAgreement >> '+ queryForAgreement);
        for(Apttus__APTS_Agreement__c agreement : Database.query(queryForAgreement)){
            agmtIdDocIdMap.put(agreement.Id, null);
        }
        // perform document text search
        //  - only if the user has entered document text search criteria

        if (String.isNotBlank(seacrhText)) {
            Map<ID, ID> verIdDocIdMap = new Map<ID, ID>();
            Map<ID, ID> docToVerMap = new Map<ID, ID>();
            Datetime lastCreateDate = Datetime.newInstance(1970, 1, 1);
            
            String tempString = '"'+seacrhText+'"';
            
            // search content
            List<List<sobject>> findList;
            List<ID> lsofConDoc = new List<id>();
            List<ContentDocumentLink> lsofConDocLink = new List<ContentDocumentLink>();
            Integer findCount = 200;
            while (findCount > 199) {
                findList = [FIND :tempString IN ALL FIELDS RETURNING 
                                        ContentVersion(id, ContentDocumentId, CreatedDate
                                                where IsLatest = true 
                                                and CreatedDate > :lastCreateDate and filetype IN ('PDF', 'docx', 'doc')
                                                order by CreatedDate)];
                
                List<ContentVersion> verList = findList[0];
                if (!verList.isEmpty()) {
                    for (ContentVersion ver : verList) {
                        lsofConDoc.add(ver.ContentDocumentId);
                        verIdDocIdMap.put(ver.Id, ver.ContentDocumentId);
                        docToVerMap.put(ver.ContentDocumentId, ver.Id);
                    }
                    
                    findCount = verList.size();
                    lastCreateDate = verList[findCount-1].CreatedDate;
    
                } else {
                    findCount = 0;
                }
            }
            
            IF(lsofConDoc.size() > 0 ){
                lsofConDocLink = [SELECT Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where ContentDocumentId In :lsofConDoc];
            }
            
            System.debug('88888888' + lsofConDocLink);
            system.debug('#######' + findList);
            system.debug('$$$$$$$' + verIdDocIdMap); 
            
            // establish agreement to doc map
            if ( !lsofConDocLink.isEmpty()) {
                Schema.DescribeSObjectResult contractAgreementDescribeResult = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe();
                System.debug(contractAgreementDescribeResult.getKeyPrefix());
                Set<ID> verIdList = verIdDocIdMap.keySet();
                for(ContentDocumentLink cdl: lsofConDocLink){
                   if(String.valueOF(cdl.LinkedEntityId).startsWith(contractAgreementDescribeResult.getKeyPrefix()) && agmtIdDocIdMap.containsKey(cdl.LinkedEntityId)) {
                       agmtIdDocIdMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                   }
               }
                
                // remove agreements which do not have associated document
                Set<ID> delKeyList = new Set<ID>();
                for (ID agmtId : agmtIdDocIdMap.keySet()) {
                    if (agmtIdDocIdMap.get(agmtId) == null) {
                        delKeyList.add(agmtId);
                    }
                }
                // remove from map
                for (ID delKey : delKeyList) {
                    agmtIdDocIdMap.remove(delKey);
                }
                
                System.debug('agmtIdDocIdMap >> ' + agmtIdDocIdMap);
            }
      
            for(Apttus__APTS_Agreement__c agreement : getAgreements(agmtIdDocIdMap.KeySet())){
                agreementList.add(New AgreementWrapper(agreement.id,agreement.Name,agreement.Apttus__FF_Agreement_Number__c,agreement.Apttus__Account__r.Name,agreement.Apttus__Status__c,agreement.Apttus__Contract_Start_Date__c,agreement.Apttus__Contract_End_Date__c,agmtIdDocIdMap.get(agreement.Id),docToVerMap.get(agmtIdDocIdMap.get(agreement.Id))));
            }
        }
        
        return agreementList;
        
    }
    
    /*
        This is a Wrapper Class.
    */
    public class AgreementWrapper{
        public Boolean isSelected{get;set;}
        public Id agreementId{get;set;}
        public String agreementName{get;set;}
        public String agreementNumber{get;set;}
        public String accountName{get;set;}
        public String status{get;set;}
        public date startDate{get;set;}
        public date endDate{get;set;}
        public Id attachmentId{get;set;}
        public Id contentVersionId {get;set;}
        public boolean isExpand {get;set;}
        
        public AgreementWrapper(Id agreementId,String agreementName,String agreementNumber,String accountName,String status,date startDate,date endDate, Id attachmentId, Id contentVersionId){
            this.isSelected = false;
            this.agreementId = agreementId;
            this.agreementName = agreementName;
            this.agreementNumber = agreementNumber;
            this.accountName = accountName;
            this.status = status;
            this.startDate = startDate;
            this.endDate = endDate;
            this.attachmentId=attachmentId;
            this.contentVersionId = contentVersionId;
            this.isExpand = false;
        }
    }
}