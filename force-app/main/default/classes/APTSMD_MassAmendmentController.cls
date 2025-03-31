public with sharing class APTSMD_MassAmendmentController {
    public List<Apttus__APTS_Agreement__c> listDisplayAgreement{get;set;}
    public List<Apttus__APTS_Agreement__c> listFilteredAgreement{get;set;}
    public Apttus__APTS_Agreement__c myAgreement {get;set;}  //for search purpose
    
    //pagination
    public List<APTSMD_AgreementWrapper> lstWrapper {get;set;}
    public List<APTSMD_AgreementWrapper> lstSetController{get;set;}
    APTSMD_CustomIterableAgreement obj;
    
    //agreement fields in form
    public Apttus__APTS_Agreement__c agreementToChange {get;set;}    
       
    public List<id> agreementIdsToGenerate; //store newly created agreements ids so we know which agreement to generate doc on.
    
    public boolean readyToGenerate {get;set;} //controls button display
    
    public Set<String> contactSet {get;set;} //store primarycontacts
    
    public String agreementString {get;set;}
    
    public string amendedAgreementString {get;set;}
    
    public List<Apttus__APTS_Agreement__c> newAgreementList {get;set;} //store agreements to display after amend, both old and new
    
    public String newAgreementListJSON {get;set;}
    
    public List<Apttus__APTS_Agreement__c> deserializedAgreements;
    
    public List<String> agreementNames = new List<String>();
    public List<String> agreementIds2 = new List<String>();
    
    
    public static String finalAgreements = 'a';
    
    public string selectedtype{get;set;}    //Store amendment type "Send/Review"
    
    public Set<Id> finalDisplayIds{get;set;}
    public Set<Id> idsToHighlight;
    public String idString{get;set;}
    
    public String expressioncrtJSON {get; set;}
    public String expressionpliJSON {get; set;}
    public string operatorTypes{get;set;}
    public string agreementIds{get;set;}
    
    // Currancy Variable initialize
    public boolean isMultiCurrancyOn {get;set;}
    public string defaultCurrancy {get;set;}
    public string dateFormat {get;set;}
    
    public APTSMD_MassAmendmentController(ApexPages.StandardController controller) {
        
        //initialize value
        myAgreement = new Apttus__APTS_Agreement__c();
        lstWrapper =  new List<APTSMD_AgreementWrapper>();
        lstSetController = new List<APTSMD_AgreementWrapper>();
        agreementToChange = new Apttus__APTS_Agreement__c();
        readyToGenerate = false;
        agreementIdsToGenerate = new List<id>();
        contactSet = new Set<String>();
        newAgreementList = new List<Apttus__APTS_Agreement__c>();
        finalAgreements = 'a';
        finalDisplayIds = new Set<id>();
        idsToHighlight = new Set<Id>();
        this.selectedtype = '';
        
        // Set currancy information
        this.defaultCurrancy = APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(true,'');
        this.isMultiCurrancyOn = Schema.getGlobalDescribe().containsKey('CurrencyType');
        this.dateFormat =  APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(false,''); 
        
        
        if(selectedtype=='Sign')
            selectedtype='Sign';
        else if(selectedtype=='Review')
            selectedtype='Review';
        else 
            selectedtype='';
            
        List<String> operatorList = new List<String>();
        operatorList.add('=');
        operatorList.add('!=');
        operatorList.add('<');
        operatorList.add('>');
        operatorList.add('<=');
        operatorList.add('>=');
        operatorList.add('Contains');
        operatorTypes=JSON.serialize(operatorList);

            
        List<expressionWrapper> expforquote = new List<expressionWrapper>();
        expressionWrapper expfor = new expressionWrapper();
        expforquote.add(expfor);
        expressioncrtJSON=JSON.serialize(expforquote);
        expressionpliJSON=JSON.serialize(expforquote);
            
        //set default values of agreementtochange
        agreementToChange.Apttus__Contract_Start_Date__c = system.today();
        agreementToChange.Apttus__Contract_End_Date__c = system.today().addYears(1);
        agreementToChange.Apttus__Amendment_Effective_Date__c = system.today().addDays(5);
                
        Map<Id, Apttus__APTS_Agreement__c> mapOfAgreements = new Map<Id, Apttus__APTS_Agreement__c>();
        mapOfAgreements = new Map<Id, Apttus__APTS_Agreement__c>([Select Id,Apttus__FF_Agreement_Number__c,Name,Apttus__Contract_Start_Date__c,APTSMD_SLA__c,RecordType.Name,
                           Apttus__Contract_End_Date__c,Apttus__Total_Contract_Value__c,
                           Apttus__Auto_Renewal__c,APTSMD_Payment_Term_Name__c, Apttus__Internal_Renewal_Notification_Days__c,
                           Apttus__Related_Opportunity__r.Name,Apttus__Related_Opportunity__c, Apttus__Status_Category__c, Apttus__Primary_Contact__c, Apttus__Primary_Contact__r.Name,
                           Apttus__Account__c, Apttus_QPComply__RelatedProposalId__c, Apttus__Version_Number__c,
                           Apttus__Status__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Term_Exception_Approval_Status__c,
                           APTSMD_Region__c, Apttus_CMConfig__PaymentTermId__c, APTSMD_Support_Exhibits__c, APTSMD_Selected__c,
                           APTSMD_Annual_Uplift__c, Apttus__Special_Terms__c, APTSMD_Amended_Terms__c, Apttus__Amendment_Effective_Date__c
                           From Apttus__APTS_Agreement__c WHERE Apttus__Status_Category__c =: 'In Effect' OR Apttus__Status_Category__c =:'Amended']); 
        
        agreementIds = '';
        for(Id agmtId : mapOfAgreements.keySet()){
            agreementIds += +agmtId+',';
        }
        agreementIds = agreementIds.substring(0, agreementIds.length()-1);
        
        listDisplayAgreement = new List<Apttus__APTS_Agreement__c>();
        listDisplayAgreement.addAll(mapOfAgreements.values());
        
        agreementString = JSON.serialize(listDisplayAgreement);
        
    }

    public pageReference onClickAmend(){
        return null;
    }
    
    public pageReference deleteAgreement(){
    String newAgreementString = ApexPages.currentPage().getParameters().get('myParam');
        List<Apttus__APTS_Agreement__c> deserializedAgreements = (List<Apttus__APTS_Agreement__c>)JSON.deserialize(newAgreementString, List<Apttus__APTS_Agreement__c>.class);
      for(Apttus__APTS_Agreement__c agrW : deserializedAgreements){
            if(agrW.APTSMD_Selected__c){
                delete agrW;
            }
        }
        String previousURL=ApexPages.currentPage().getHeaders().get('Referer');
        return new pagereference(previousURL); 
    }
    
    List<Apttus__APTS_Agreement__c> amendedAgmtList2 = new List<Apttus__APTS_Agreement__c>();
    
    // doMassAmendNew() - New function for better effeciency for mass amendment
    public void doMassAmendNew(){
        Apttus__APTS_Agreement__c thisAgreement;
        Apttus__APTS_Agreement__c oldAgr;
        List<Apttus__APTS_Related_Agreement__c> relatedAgmt = new List<Apttus__APTS_Related_Agreement__c>();
       
        Id generatedId;
        String newAgreementString = ApexPages.currentPage().getParameters().get('myParam');

        deserializedAgreements = (List<Apttus__APTS_Agreement__c>)JSON.deserialize(newAgreementString, List<Apttus__APTS_Agreement__c>.class);
        
        List<Apttus__APTS_Agreement__c> amendedAgmtList = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> oldAgmtWhichHasToUpdate = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__Agreement_Clause__c> agmtClause = new List<Apttus__Agreement_Clause__c>();
       
        List<Id> OldAgmtIds = new List<Id>();
        
        idsToHighlight = new Set<Id>();        
        //go through all agreements and find the selected ones
        
        System.debug('deserializedAgreements' + deserializedAgreements);
      
        for(Apttus__APTS_Agreement__c agrW : deserializedAgreements){
            if(agrW.APTSMD_Selected__c){
                System.debug('agrW' + agrW);
                agrW.Apttus__Status__c = 'Being Amended';
                agrW.Apttus__Status_Category__c = 'In Effect';
                oldAgmtWhichHasToUpdate.add(agrW.clone(true,true,false,false));
                if(agrw.Apttus__FF_Agreement_Number__c != '' && agrw.Apttus__FF_Agreement_Number__c != null){
                    agrw.Apttus__Agreement_Number__c = agrw.Apttus__FF_Agreement_Number__c.split('\\.')[0];
                }
                finalDisplayIds.add(agrW.Id); //to display selected record on Final page 
                OldAgmtIds.add(agrw.Id);
                thisAgreement = new Apttus__APTS_Agreement__c();
                thisAgreement = agrW; //copy the superseded agreement
                thisAgreement.Apttus__Parent_Agreement__c = agrw.ID;
                thisAgreement.id = null;
                thisAgreement.Apttus__Status__c='Ready for Signatures';
                thisAgreement.Apttus__Status_Category__c='In Signatures';
                thisAgreement.Apttus_Approval__Approval_Status__c='None';
                thisAgreement.Apttus__LatestDocId__c=agrW.name;//Apttus__LatestDocId__c Used as a temp storage
                thisAgreement.Apttus_CMConfig__PONumber__c= agrw.Apttus__FF_Agreement_Number__c;//Apttus_CMConfig__PONumber__c Used as a temp storage
                thisAgreement.name = agrW.Name + ' Amended';
                thisAgreement.APTSMD_MassAmended__c = true; // to identify that Agreement was amended by the Mass Amendment                                                       
                
                thisAgreement.Apttus__Agreement_Number__c = agrW.Apttus__Agreement_Number__c;//This will now create proper Agreement number for new agreements
                
                agreementNames.add(thisAgreement.name);
                agreementIds2.add(thisAgreement.Apttus__Agreement_Number__c);
                
                //Odeh: Update Version Number
                List<Apttus__APTS_Agreement__c> checkVerNum = [SELECT Id, Apttus__Agreement_Number__c, Apttus__Version_Number__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Agreement_Number__c =: agrW.Apttus__Agreement_Number__c];               
                Decimal newVerNum = agrW.Apttus__Version_Number__c;  
                for(Apttus__APTS_Agreement__c agmt : checkVerNum){
                    if ( agmt.Apttus__Version_Number__c > agrW.Apttus__Version_Number__c)
                        newVerNum = agmt.Apttus__Version_Number__c;
                }
                
                thisAgreement.Apttus__Version_Number__c = newVerNum + 1;
                
                if(agreementToChange.Apttus__Contract_Start_Date__c != null){
                    thisAgreement.Apttus__Contract_Start_Date__c = agreementToChange.Apttus__Contract_Start_Date__c;
                }
                if(agreementToChange.Apttus__Contract_End_Date__c != null){
                    thisAgreement.Apttus__Contract_End_Date__c = agreementToChange.Apttus__Contract_End_Date__c;
                }
                if(agreementToChange.Apttus__Amendment_Effective_Date__c != null){
                    thisAgreement.Apttus__Amendment_Effective_Date__c = agreementToChange.Apttus__Amendment_Effective_Date__c;
                }
                if(agreementToChange.APTSMD_Amended_Terms__c != null){
                    thisAgreement.APTSMD_Amended_Terms__c = agreementToChange.APTSMD_Amended_Terms__c;
                }
                
                thisAgreement.APTSMD_Sign_or_Review__c=selectedtype;
                
                thisAgreement.APTSMD_Selected__c = false;
                
                //insert thisAgreement; 
                amendedAgmtList.add(thisAgreement);
                
                
            }
        }
        
        List<Apttus__APTS_Related_Agreement__c> relatedAgrmt = [select Apttus__APTS_Contract_From__c from Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_To__c in :finalDisplayIds];
        
        if(relatedAgrmt.size()>0){
            List<Id> agrtmId = new List<Id>();
            for(Apttus__APTS_Related_Agreement__c temp:relatedAgrmt){
                agrtmId.add(temp.Apttus__APTS_Contract_From__c);
            }
            
            List<Apttus__APTS_Agreement__c> agrmtList = [select id,Apttus__Status__c,Apttus__Status_Category__c from Apttus__APTS_Agreement__c where id in :agrtmId];
            
            if(agrmtList.size()>0){
                for(Apttus__APTS_Agreement__c temp : agrmtList){
                    temp.Apttus__Status__c='Superseded';
                    temp.Apttus__Status_Category__c='Amended';
                }
                
                update agrmtList;
            }
        }
        
        // Update deserializedAgreements
        for(Apttus__APTS_Agreement__c tempAgr : oldAgmtWhichHasToUpdate){
            tempAgr.APTSMD_Selected__c = false;
        }
        update oldAgmtWhichHasToUpdate;
        
        // insert amended agreements
        insert amendedAgmtList;
        
        if(amendedAgmtList!=null && amendedAgmtList.size()>0){
            amendedAgmtList2=amendedAgmtList;    
        }
        
        
        // Loop through amended Agreement List
        for(integer i = 0; i < amendedAgmtList.size() ; i++){
            
              
                 //insert Agreement Clause if Amended Term is added
                 if(agreementToChange.APTSMD_Amended_Terms__c != null){
                    
                    Apttus__Agreement_Clause__c clause = new Apttus__Agreement_Clause__c();
                    clause.Apttus__Agreement__c = amendedAgmtList[i].id;
                    clause.Apttus__Clause__c = 'Amended Term';
                    clause.Apttus__Active__c = true;
                    clause.Apttus__Text__c = agreementToChange.APTSMD_Amended_Terms__c;
                    clause.Apttus__Action__c = 'Inserted';
                    //insert clause;
                    agmtClause.add(clause);

                }
                finalDisplayIds.add(amendedAgmtList[i].id); //to display selected record on Final page 
                idsToHighlight.add(amendedAgmtList[i].id);
                //add primarycontact
                if(amendedAgmtList[i].Apttus__Primary_Contact__c != null){
                    contactSet.add(amendedAgmtList[i].Apttus__Primary_Contact__c);
                }

                
                agreementIdsToGenerate.add(amendedAgmtList[i].id); //store the ids of agreements we just added.
                
                 /* Create related agreement record for both old and new agreement*/
                Apttus__APTS_Related_Agreement__c relatedAgr = new Apttus__APTS_Related_Agreement__c();
                relatedAgr.Name = 'Current Agreement'; 
                relatedAgr.Apttus__APTS_Contract_From__c = OldAgmtIds[i];
                relatedAgr.Apttus__Relationship_From_Type__c = 'Is Amended By';
                relatedAgr.Apttus__APTS_Contract_To__c = amendedAgmtList[i].ID;
                relatedAgr.Apttus__Relationship_To_Type__c = 'Is Amended For';
                
                //insert relatedAgr;
                
                readyToGenerate = true;
            
        }
        
        // Insert clause
        insert agmtClause;
        insert relatedAgmt;
        
        populateNewAgreementList();
        doGenerate();
    }
    
    // Unused
    public void doMassAmend(){
        Apttus__APTS_Agreement__c thisAgreement;
        Apttus__APTS_Agreement__c oldAgr;
        Id generatedId;
        String newAgreementString = ApexPages.currentPage().getParameters().get('myParam');

        deserializedAgreements = (List<Apttus__APTS_Agreement__c>)JSON.deserialize(newAgreementString, List<Apttus__APTS_Agreement__c>.class);
        
      
        idsToHighlight = new Set<Id>();        
        //go through all agreements and find the selected ones
        for(Apttus__APTS_Agreement__c agrW : deserializedAgreements){
            if(agrW.APTSMD_Selected__c){
                
                //--Change old agreements to superseded--
                oldAgr = [Select id, Apttus__Status__c, Apttus__Version_Number__c, Apttus__Status_Category__c,Apttus__Primary_Contact__c,Apttus__Agreement_Number__c from Apttus__APTS_Agreement__c where id =: agrW.Id];
                oldAgr.Apttus__Status__c = 'Superseded';
                oldAgr.Apttus__Status_Category__c = 'Amended';
                update oldAgr;
                

                finalDisplayIds.add(agrW.Id); //to display selected record on Final page 
                thisAgreement = new Apttus__APTS_Agreement__c();
                thisAgreement = agrW; //copy the superseded agreement
                thisAgreement.id = null;
                thisAgreement.name = agrW.Name + ' Amended';
                thisAgreement.APTSMD_MassAmended__c = true; // to identify that Agreement was amended by the Mass Amendment                                                       
                
                thisAgreement.Apttus__Agreement_Number__c = oldAgr.Apttus__Agreement_Number__c;//This will now create proper Agreement number for new agreements
                
                agreementNames.add(thisAgreement.name);
                agreementIds2.add(thisAgreement.Apttus__Agreement_Number__c);
                
                //Odeh: Update Version Number
                List<Apttus__APTS_Agreement__c> checkVerNum = [SELECT Id, Apttus__Agreement_Number__c, Apttus__Version_Number__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Agreement_Number__c =: oldAgr.Apttus__Agreement_Number__c];               
                
                Decimal newVerNum = oldAgr.Apttus__Version_Number__c;  
                
                for(Apttus__APTS_Agreement__c agmt : checkVerNum){
                    if ( agmt.Apttus__Version_Number__c > oldAgr.Apttus__Version_Number__c)
                        newVerNum = agmt.Apttus__Version_Number__c;
                }
                
                thisAgreement.Apttus__Version_Number__c = newVerNum + 1;
                
                if(agreementToChange.Apttus__Contract_Start_Date__c != null){
                    thisAgreement.Apttus__Contract_Start_Date__c = agreementToChange.Apttus__Contract_Start_Date__c;
                }
                if(agreementToChange.Apttus__Contract_End_Date__c != null){
                    thisAgreement.Apttus__Contract_End_Date__c = agreementToChange.Apttus__Contract_End_Date__c;
                }
                if(agreementToChange.Apttus__Amendment_Effective_Date__c != null){
                    thisAgreement.Apttus__Amendment_Effective_Date__c = agreementToChange.Apttus__Amendment_Effective_Date__c;
                }
                if(agreementToChange.APTSMD_Amended_Terms__c != null){
                    thisAgreement.APTSMD_Amended_Terms__c = agreementToChange.APTSMD_Amended_Terms__c;
                }
                
                thisAgreement.APTSMD_Sign_or_Review__c=selectedtype;
                
                thisAgreement.APTSMD_Selected__c = false;
                
                //create "amended" agreement
                insert thisAgreement; 
                //insert Agreement Clause if Amended Term is added
                 if(agreementToChange.APTSMD_Amended_Terms__c != null){
                    
                    Apttus__Agreement_Clause__c clause = new Apttus__Agreement_Clause__c();
                    clause.Apttus__Agreement__c = thisAgreement.id;
                    clause.Apttus__Clause__c = 'Amended Term';
                    clause.Apttus__Active__c = true;
                    clause.Apttus__Text__c = agreementToChange.APTSMD_Amended_Terms__c;
                    clause.Apttus__Action__c = 'Inserted';
                    insert clause;

                }
                finalDisplayIds.add(thisAgreement.Id); //to display selected record on Final page 
                idsToHighlight.add(thisAgreement.Id);
                //add primarycontact
                if(thisAgreement.Apttus__Primary_Contact__c != null){
                    contactSet.add(thisAgreement.Apttus__Primary_Contact__c);
                }

                
                agreementIdsToGenerate.add(thisAgreement.id); //store the ids of agreements we just added.
                
                 /* Create related agreement record for both old and new agreement*/
                Apttus__APTS_Related_Agreement__c relatedAgr = new Apttus__APTS_Related_Agreement__c();
                relatedAgr.Name = 'Current Agreement'; 
                relatedAgr.Apttus__APTS_Contract_From__c = oldAgr.ID;
                relatedAgr.Apttus__Relationship_From_Type__c = 'Is Amended By';
                relatedAgr.Apttus__APTS_Contract_To__c = thisAgreement.ID;
                relatedAgr.Apttus__Relationship_To_Type__c = 'Is Amended For';
                
                insert relatedAgr;
                
                readyToGenerate = true;

            }
        }
        populateNewAgreementList();
        doGenerate();
    }
    
    public void populateNewAgreementList(){
    
    
        newAgreementList.clear();
        newAgreementList = [Select Id,RecordType.Name,Apttus__Agreement_Number__c,Name,Apttus__Contract_Start_Date__c,APTSMD_SLA__c,
                           Apttus__Contract_End_Date__c,Apttus__Total_Contract_Value__c,
                           Apttus__Auto_Renewal__c,APTSMD_Payment_Term_Name__c, Apttus__Internal_Renewal_Notification_Days__c,
                           Apttus__Related_Opportunity__r.Name,Apttus__Related_Opportunity__c, Apttus__Status_Category__c, Apttus__Primary_Contact__c, Apttus__Primary_Contact__r.Name,
                           Apttus__Account__c, Apttus_QPComply__RelatedProposalId__c, Apttus__Version_Number__c,
                           Apttus__Status__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Term_Exception_Approval_Status__c,
                           APTSMD_Region__c, Apttus_CMConfig__PaymentTermId__c, APTSMD_Support_Exhibits__c, APTSMD_Selected__c,
                           APTSMD_Annual_Uplift__c, Apttus__Special_Terms__c, APTSMD_Amended_Terms__c, Apttus__Amendment_Effective_Date__c
                           From Apttus__APTS_Agreement__c WHERE Id In :finalDisplayIds]; 
                           
       amendedAgreementString = JSON.serialize(newAgreementList);
       newAgreementListJSON = JSON.serialize(newAgreementList);
       idString = String.join(new List<Id>(idsToHighlight),',');
      }
    public void doGenerate()
    {
        String sessionId = userInfo.getSessionId();
        for(String tempId : agreementIdsToGenerate){
            generateDocument(tempId, sessionId);
        }
        //send email if primary contact is not empty
        for(String temp : contactSet){
            SendEmail(temp); 
        }
    }



    @future(callout=true)
    public static void generateDocument(Id recordId, String sessionId)
    {
        Apttus__APTS_Template__c templateAmendment;
        Id generatedDocId; //return value
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting = [SELECT Id, Name, APTSMD_Agreement_Amendment_Template__c 
                        FROM APTSMD_Apttus_PreSales_Config_Settings2__c WHERE Name = 'System Properties' LIMIT 1];
        if(presalesSetting.APTSMD_Agreement_Amendment_Template__c == '' || presalesSetting.APTSMD_Agreement_Amendment_Template__c == null){
            return;
        }
        try{
            if(presalesSetting.APTSMD_Agreement_Amendment_Template__c != ''){
                templateAmendment = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name = :presalesSetting.APTSMD_Agreement_Amendment_Template__c LIMIT 1];
                system.debug('Presales setting:' + templateAmendment.Name);
            }
        }catch(exception ex){
            throw ex;
        }
        
        Id templateId = templateAmendment.Id;
        String accessLevel = 'Insert comments and tracked changes only';    
        String docFormat = 'DOCX';   
        String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
        try{
      
            generatedDocId = Apttus.MergeWebService.generateDoc(templateId
                , recordId
                , accessLevel
                , docFormat
                , sessionId
                , apiServerURL);
        }catch(exception ex){
            System.debug('Exception in the try catch: '+ ex);
        }
        
        Apttus__APTS_Agreement__c agrmt = [select id,name,Apttus__Status__c,Apttus__Status_Category__c,APTSMD_Sign_or_Review__c from Apttus__APTS_Agreement__c where id=:recordId limit 1];
        
        
        if(agrmt.APTSMD_Sign_or_Review__c=='Review'){
        agrmt.Apttus__Status_Category__c = 'In Authoring';
        agrmt.Apttus__Status__c = 'Other Party Review';
        update agrmt;}
        
        
    }
    
    
    public void sendEmail(String contactId)
    {
        
        try{
            
       
          List<Apttus__APTS_Related_Agreement__c> relatedAgreementList=new List<Apttus__APTS_Related_Agreement__c>();
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactId);
        mail.setSubject('Agreements Successfully Amended');
        
        String body = 'Dear ' + userinfo.getName() + ', <br/><br/>These following agreements are sucessfully amended:<br/> ';
      
        String tempId;
        for(String s:agreementIds2){
            tempId=s;
        }
        
        if(amendedAgmtList2!=null && amendedAgmtList2.size()>0){
            
            integer flag=0;
            
        for(Apttus__APTS_Agreement__c temp:amendedAgmtList2){
            Apttus__APTS_Related_Agreement__c tempRelatedAgrmeent = new Apttus__APTS_Related_Agreement__c();
            tempRelatedAgrmeent.name='Current Agreement';
            tempRelatedAgrmeent.Apttus__APTS_Contract_From__c=temp.Apttus__Parent_Agreement__c;
            tempRelatedAgrmeent.Apttus__Relationship_From_Type__c='Is Amended By';
            tempRelatedAgrmeent.Apttus__APTS_Contract_To__c=temp.id;
            tempRelatedAgrmeent.Apttus__Relationship_To_Type__c='Is Amendment For';
            relatedAgreementList.add(tempRelatedAgrmeent);
            
            if(temp.Apttus__LatestDocId__c != null){
            body = body + 'Original Agreement Name : ' +temp.Apttus__LatestDocId__c + '<br/>';
       }
       
       

             if(temp.Apttus_CMConfig__PONumber__c != null){
            body = body + 'Original Agreement Number : ' +temp.Apttus_CMConfig__PONumber__c + '<br/>';
       }
            
        temp.Apttus__Parent_Agreement__c=null;
        temp.Apttus__LatestDocId__c='';
        temp.Apttus_CMConfig__PONumber__c='';
        if(temp.name != null){
            body = body + 'Amended Agreement Name : ' + temp.name + '<br/>';
       }
       
       if(temp.Apttus__Agreement_Number__c != null && temp.Apttus__Version_Number__c!=null){
            body = body + 'Amended Agreement Number : ' + temp.Apttus__Agreement_Number__c +'.'+  temp.Apttus__Version_Number__c+ '<br/>';
       }
       
        if(temp.Apttus__Contract_Start_Date__c != null){
            body = body + 'Agreement Start Date: ' + temp.Apttus__Contract_Start_Date__c + '<br/>';
        }
        if(temp.Apttus__Contract_End_Date__c != null){
            body = body + 'Agreement End Date: ' + temp.Apttus__Contract_End_Date__c + '<br/>';
        }
        if(temp.Apttus__Amendment_Effective_Date__c != null){
            body = body + 'Amendment Effective Date: ' + temp.Apttus__Amendment_Effective_Date__c + '<br/>';
        }
        if(temp.APTSMD_Amended_Terms__c != null){
            body = body + 'Amended Terms: ' + temp.APTSMD_Amended_Terms__c + '<br/>';
        }
        flag++;
        
        if(amendedAgmtList2.size()>flag)
        body=body+'=========================================================== <br/><br/>';
            
        }
        
        Insert relatedAgreementList;
       update amendedAgmtList2;
       
            
        }
    
        mail.setHTMLBody(body);
        
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        if (!results.get(0).isSuccess()) {
            System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
            String errorMessage = results.get(0).getErrors()[0].getMessage();
        }
        }catch(EmailException e){
            System.debug('Exception :' + e.getCause());
            System.debug('Exception :' + e.getMessage());
          
        }
     }
     
     /*
      * @Chintan
      * Get all the fields of Object (API Name passed in parameter)
      */
    @RemoteAction
    public static List<Map<String,String>> getObjectFields(String objectAPIName){
        List<Map<String,String>> fieldMap;
        try{
            fieldMap= getAllFields(objectAPIName);
        }catch(Exception e){}
        return fieldMap;
    }
    
    public static List<Map<String,String>> getAllFields(String objectName){
        String selects = '';
     
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Map<String,String>  selectFields = new Map<String,String> ();
        List<Map<String,String>> mapList = new List<Map<String,String>>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.put(fd.getLabel(),fd.getName());
            }
        }
        Map<String,String> fieldTypeMap = getAllFieldType(objectName);
        Map<String,String> referenceMap = getReferenceAPIMap(objectName);
        mapList.add(selectFields);
        mapList.add(fieldTypeMap);
        mapList.add(referenceMap);
        return mapList;
    }
    
    public static Map<String,string> getAllFieldType(String stype){
        Schema.SObjectType objectName = Schema.getGlobalDescribe().get(stype);
        Schema.DescribeSObjectResult objectDescribe =objectName.getDescribe();
        string  objectLabel=objectDescribe.getLabel(); 
        
        Map<String,String> referenceMap = new Map<String,String>();
        Map<String,String> referenceLabel = new Map<String,String>();
        
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(stype.toLowerCase()).getDescribe().Fields.getMap();
        
        list<string> allFields = new list<string>();
        
        Map<String,String> attributeFieldMap = new Map<String,String>();
        Map<String,Schema.DisplayType> attributeFieldTypeMap = new Map<String,Schema.DisplayType>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    String APIName = String.valueOf(fd.getReferenceTo());
                    referenceMap.put(String.valueOf(fd.getName()),String.valueOf(fd.getType()));
            }
        }
        // code to get reference fields,all fields of object - end
        return referenceMap;
    }
    
    public static  Map<String,String> getReferenceAPIMap(String stype){
        
        Map<String,String> referenceMap= new Map<String,String>();
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(stype.toLowerCase()).getDescribe().Fields.getMap();
        
        list<string> allFields = new list<string>();
        
        Map<String,String> attributeFieldMap = new Map<String,String>();
        Map<String,Schema.DisplayType> attributeFieldTypeMap = new Map<String,Schema.DisplayType>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if(String.valueOf(fd.getType()) =='REFERENCE'){
                    String APIName = String.valueOf(fd.getReferenceTo());
                    referenceMap.put(String.valueOf(fd.getName()),APIName.substring(1,APIName.length()-1));
                }
            }
        }
         return referenceMap;
    }
     
     public class expressionWrapper{
        public string fieldname{get;set;}
        public string operator{get;set;}
        public string value{get;set;}
        public String andor{get;set;}
        public String colorand{get;set;}
        public String fontcolorand{get;set;}
        public String coloror{get;set;}
        public String fontcoloror{get;set;}
        public Integer sequence {get;set;}
        
        public List<String> pickListValues{get;set;}
        public map<id,String> referncevalue{get;set;}
        public expressionWrapper(){
            this.fieldname = '';
            this.operator = ''; 
            this.value = '';
            this.colorand = 'White';
            this.fontcolorand = 'Black';
            this.coloror = 'White';
            this.fontcoloror = 'Black';
            this.sequence = 1;
        }
    }
    
    @RemoteAction
    public static List<String>  getPicklistValues(String obj,String fieldAPI){
        List<String> fieldMetaData;
        try{
           fieldMetaData=getPicklistValuesForField(obj,fieldAPI);
            
        }catch(Exception e){
            
        }
        return fieldMetaData;
    }
    
    public static List<String> getPicklistValuesForField(String ObjectApi_name,String Field_name){ 

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
    }
    
    @RemoteAction
    public static map<id,String>  getReferenceRecords(String objAPI){
        map<id,String> recordList= new map<id,String>();
        try{
            String query = 'select id,name from '+objAPI;
            List<sObject> objectRecords = database.query(query);
            if(!objectRecords.isEmpty()){
                for(sObject obj : objectRecords){
                    recordList.put(String.valueOf(obj.get('id')),String.valueOf(obj.get('Name')));
                }
            }
        }catch(Exception e){}
        return recordList;
    }
    
    @RemoteAction
    public static String getAgmtsAsPerCondition(String param, String agmtIdsStr){
        agmtIdsStr = agmtIdsStr.replaceAll(',', '\',\'');
        
        String query = 'Select Id,RecordType.Name,Apttus__FF_Agreement_Number__c,Name,Apttus__Contract_Start_Date__c,APTSMD_SLA__c, Apttus__Contract_End_Date__c,Apttus__Total_Contract_Value__c, Apttus__Auto_Renewal__c,APTSMD_Payment_Term_Name__c, Apttus__Internal_Renewal_Notification_Days__c, Apttus__Related_Opportunity__r.Name, Apttus__Related_Opportunity__c, Apttus__Status_Category__c, Apttus__Primary_Contact__c, Apttus__Primary_Contact__r.Name, Apttus__Account__c, Apttus_QPComply__RelatedProposalId__c, Apttus__Version_Number__c, Apttus__Status__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Term_Exception_Approval_Status__c, APTSMD_Region__c, Apttus_CMConfig__PaymentTermId__c, APTSMD_Support_Exhibits__c, APTSMD_Selected__c, APTSMD_Annual_Uplift__c, Apttus__Special_Terms__c, APTSMD_Amended_Terms__c, Apttus__Amendment_Effective_Date__c From Apttus__APTS_Agreement__c WHERE Id in (\''+agmtIdsStr+'\') AND '+param;
        
        List<Apttus__APTS_Agreement__c> listOfAgreements = database.query(query);
        return JSON.serialize(listOfAgreements);
    }
    
}