public class APTSMD_AgreementPortalController {
    
    public String eContractingAgreementJSON {get;set;}
    public String accountJSON {get;set;}
    public String paymentTermsJSON {get;set;}
    public String supportExhibitsJSON {get;set;}
    public String regionJSON {get;set;}
    public String accountObj {get;set;}
    public String contactObj {get;set;}
     
    public APTSMD_AgreementPortalController(){
        paymentTermsJSON = JSON.serialize(getPaymentTerms());
        supportExhibitsJSON = JSON.serialize(getSupportExhibits());
        regionJSON = JSON.serialize(getRegion());
        User user = [Select Id,
                            Contact.Id,
                            Contact.Account.Id 
                    From User 
                    where Id = :UserInfo.getUserId()];
        if(user!=null){
           List<contact> listOfContact = [select Id,Name from contact where Id =:user.Contact.Id];
           if(listOfContact!=null && listOfContact.size() > 0){
               ContactWrapper wrapper = new ContactWrapper();
               wrapper.id = listOfContact[0].Id;
               wrapper.Name = listOfContact[0].Name;
               contactObj = JSON.serialize(wrapper);
           }else{
               contactObj = JSON.serialize(new ContactWrapper()); 
           }
           List<Account> listOfAccount = [select Id,Name from Account where Id =:user.Contact.Account.Id];
           if(listOfAccount!=null && listOfAccount.size() > 0){
               AccountWrapper wrapper = new AccountWrapper();
               wrapper.id = listOfAccount[0].Id;
               wrapper.Name = listOfAccount[0].Name;
               accountObj = JSON.serialize(wrapper);
           }else{
               accountObj = JSON.serialize(new AccountWrapper());
           }
           accountJSON = JSON.serialize(getAccountOfUser(user.Contact.Account.Id));
        }else{
            accountJSON = JSON.serialize(getAccounts());
        }
         
    }
    
    public static Date convertToDate(Date dt){
       return date.newinstance(dT.year(), dT.month(), dT.day());
    }
    
    public List<AccountWrapper> getAccounts(){
       List<AccountWrapper> accountWrapper = new List<AccountWrapper>();
       Account acc = APTSMD_AgreementPortalConstant.account;
       if(acc!=null){
           AccountWrapper wrapper = new AccountWrapper();
           wrapper.id=acc.id;
           wrapper.name=acc.name;
           accountWrapper.add(wrapper);
       }
       return accountWrapper;
    }
    
    public List<AccountWrapper> getAccountOfUser(Id accountId){
       List<AccountWrapper> accountWrapper = new List<AccountWrapper>();
       List<Account> listOfAccount = [select Id,Name from Account where Id =:accountId];
       if(listOfAccount!=null && listOfAccount.size() > 0){
           AccountWrapper wrapper = new AccountWrapper();
           wrapper.id = listOfAccount[0].Id;
           wrapper.Name = listOfAccount[0].Name;
           accountWrapper.add(wrapper);
       }
       return accountWrapper;
    }
    
    public static List<KeyValueWrapper> getPaymentTerms(){
        //   Schema.DescribeFieldResult fieldResult = Apttus_Config2__PaymentTerm__c.Name.getDescribe();
        //   if(fieldResult!=null){
        //       return getPickListValues(fieldResult);
        //   }
          //Logic has been modified here by Devangi to query payment terms object instead of creating a picklist field for it on Agreement object
          List<KeyValueWrapper> keyValuePair = new List<KeyValueWrapper>();
          List<Apttus_Config2__PaymentTerm__c> paymentTermList = [SELECT Id,
                                                                          Name,
                                                                          Apttus_Config2__Label__c
                                                                 FROM Apttus_Config2__PaymentTerm__c];
          if(paymentTermList.size() > 0){
              for(Apttus_Config2__PaymentTerm__c paymentTerm : paymentTermList){
                  KeyValueWrapper wrapper = new KeyValueWrapper();
                  wrapper.label = paymentTerm.Apttus_Config2__Label__c;
                  wrapper.value = paymentTerm.Name;
                  keyValuePair.add(wrapper);
              }
              return keyValuePair;
          }
          return null;
    }
    
    public static List<KeyValueWrapper> getRegion(){
          Schema.DescribeFieldResult fieldResult = Apttus__APTS_Agreement__c.APTSMD_Region__c.getDescribe();
          if(fieldResult!=null){
              return getPickListValues(fieldResult);
          }
          return null;
    }
    
    public static List<KeyValueWrapper> getSupportExhibits(){
          Schema.DescribeFieldResult fieldResult = Apttus__APTS_Agreement__c.APTSMD_Support_Exhibits__c.getDescribe();
          if(fieldResult!=null){
              return getPickListValues(fieldResult);
          }
          return null;
    }
    
    public static List<KeyValueWrapper> getPickListValues(Schema.DescribeFieldResult fieldResult){
        List<KeyValueWrapper> keyValuePair = new List<KeyValueWrapper>();
          if(fieldResult!=null){
              List<Schema.PicklistEntry> plv = fieldResult.getPicklistValues();
              for(Schema.PicklistEntry f : plv){
                  KeyValueWrapper wrapper = new KeyValueWrapper();
                  wrapper.label = f.getLabel();
                  wrapper.value = f.getValue();
                  keyValuePair.add(wrapper);
              }
          }
          return keyValuePair;
    }
    public static List<AgreementWrapper> getListOfAgreementBasedOnAccount(String userId){
        List<AgreementWrapper> result = new List<AgreementWrapper>();
        User user = [Select Id,Contact.Account.Id From User where Id = :userId];
        if(user!=null){
            Account acc = user.Contact.Account;
            if(acc!=null){
                List<Apttus__APTS_Agreement__c> listOfAgreement = [select Id,
                                                                          name,
                                                                          RecordType.Name,
                                                                          Apttus__Contract_Start_Date__c,
                                                                          Apttus__Contract_End_Date__c,
                                                                          CreatedDate,
                                                                          Apttus__Primary_Contact__r.Name,
                                                                          Apttus__FF_Agreement_Number__c,
                                                                          Apttus__Account__r.Id,
                                                                          Apttus__Account__r.Name,
                                                                          Apttus__Status_Category__c,
                                                                          Apttus__Status__c,
                                                                          Apttus__Total_Contract_Value__c 
                                                                    from Apttus__APTS_Agreement__c 
                                                                    where Apttus__Account__c=:acc.Id 
                                                                    order by CreatedDate desc];
                if(listOfAgreement!=null && listOfAgreement.size() > 0 ){
                    Integer counter = 0;
                    for(Apttus__APTS_Agreement__c agreement : listOfAgreement){
                        counter = counter + 1;
                        AgreementWrapper wrapper = new AgreementWrapper();
                        wrapper.agreementId = agreement.Id;
                        wrapper.agreementNumber = agreement.Apttus__FF_Agreement_Number__c;
                        wrapper.agreementName = agreement.name;
                        wrapper.primaryContact = agreement.Apttus__Primary_Contact__r.Name;
                        wrapper.status = agreement.Apttus__Status__c;
                        wrapper.recordTypeName = agreement.RecordType.Name;
                        wrapper.contractValue = agreement.Apttus__Total_Contract_Value__c;
                        wrapper.startDate = agreement.Apttus__Contract_Start_Date__c;
                        wrapper.endDate = agreement.Apttus__Contract_End_Date__c;
                        wrapper.createdDate = agreement.CreatedDate;
                        wrapper.srNo = counter;
                        wrapper.accountId = agreement.Apttus__Account__r.Id;
                        wrapper.accountName = agreement.Apttus__Account__r.Name;
                        wrapper.category = agreement.Apttus__Status_Category__c;
                        result.add(wrapper);
                    }    
                }
            }
        }
        return result;
    }
     
    @RemoteAction
    public static String getAgreement(){
        String userid = UserInfo.getUserId();
        return JSON.serialize(getListOfAgreementBasedOnAccount(userid));
    }
    
    @RemoteAction
    public static String create(String data){
       AccountAndContactWrapper wrapper = (AccountAndContactWrapper)JSON.deserialize(data, AccountAndContactWrapper.class);    
       if(wrapper!=null){
           Account acc = APTSMD_AgreementPortalConstant.account;
           if(acc!=null){
               try{
               Contact cont = new Contact();
               cont.AccountId = acc.Id;
               cont.MobilePhone = wrapper.phone;
               cont.Email = 'apttussigner@apttus.com';
               cont.FirstName = wrapper.firstName;
               cont.LastName = wrapper.lastName;
               Database.insert(cont);
                
                //Create user
                Profile portalProfile = APTSMD_AgreementPortalConstant.portalProfile;
                Integer len = 5;
                Blob blobKey = crypto.generateAesKey(128);
                String key = EncodingUtil.convertToHex(blobKey);
                String pwd = key.substring(0,len);
                User user1 = new User(
                    Username = wrapper.email+'_'+pwd,
                    ContactId = cont.Id,
                    ProfileId = portalProfile.Id,
                    CommunityNickname = pwd+'_'+wrapper.firstName,
                    Alias = pwd.substring(0,4),
                    Email = wrapper.email,
                    EmailEncodingKey = 'UTF-8',
                    FirstName = wrapper.firstName,
                    LastName = wrapper.lastName,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US',
                    isActive = true
                );
                Database.insert(user1);
                if(user1!=null){
                    Database.DMLOptions dlo = new Database.DMLOptions();
                    dlo.EmailHeader.triggerUserEmail = false;
                    Database.insert(user1,dlo);
                    return user1.Id;
                }
               }catch(Exception e){
                   system.debug('error' +e);
                   return APTSMD_AgreementPortalConstant.Fail;
               }
           }
           
       }
      return APTSMD_AgreementPortalConstant.Fail;
    }
    @RemoteAction
    public static String assignPermissionSet(String uid){
        String userId = (String)JSON.deserialize(uid, String.class);    
        User user1 = [ select Id from User where Id = :userId];
        if(user1!=null){
            String[] permissionSet = APTSMD_AgreementPortalConstant.PERMISSION_SET.split(',');//'GrrenTech_eCommerce_Permissions_2','APTTUS_Agreement_Permission_Set','Partner_User','APTSMD_Partner_Community'
            List<PermissionSet> pselist = [SELECT Id,Name FROM PermissionSet WHERE Name IN :permissionSet];
            if(pselist!=null && pselist.size() > 0){
                List<PermissionSetAssignment> perSet = new List<PermissionSetAssignment>();
                for(PermissionSet temp: pselist) {
                    PermissionSetAssignment tempass = new PermissionSetAssignment();
                    tempass.AssigneeId = user1.Id;
                    tempass.PermissionSetId = temp.Id;
                    perSet.add(tempass);
                    
                }
                if(perSet!=null && perSet.Size()>0) {
                   insert perSet;
                   return APTSMD_AgreementPortalConstant.SUCCESS;
                }
            }
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    
    @RemoteAction
    public static PageReference loginToSite(String loginUser,String loginPassword){
        if(loginUser!=null && loginPassword!=null){
            String userName = (String)JSON.deserialize(loginUser, String.class);    
            String pass = (String)JSON.deserialize(loginPassword, String.class);
            PageReference newPage = Site.login(userName, pass,'/'+APTSMD_AgreementPortalConstant.PortalHomePage);
            if(newPage!=null){
                newPage.setRedirect(true);
                return newPage;
            }
        }
        return null;
    }
    
    @RemoteAction
    public static List<ContactWrapper> getContactByAccountName(String accID){
       List<ContactWrapper> contactWrapper = new List<ContactWrapper>();
       String accountId = (String)JSON.deserialize(accId, String.class);    
       if(accountId!=null && accountId!=''){
           List<Contact> listOfContact = [select Id,Name from contact where AccountId =:accountId and Name =:UserInfo.getName()];
           if(listOfContact!=null && listOfContact.size() > 0){
               for(Contact con : listOfContact){
                   ContactWrapper wrapper = new ContactWrapper();
                   wrapper.id=con.id;
                   wrapper.name=con.name;
                   contactWrapper.add(wrapper);
               }
           }else{
               List<Contact> listOfAccountContact = [select Id,Name from contact where AccountId =:accountId and Name !=:APTSMD_AgreementPortalConstant.CONTACT_NAME];
               if(listOfAccountContact!=null && listOfAccountContact.size() > 0){
                   for(Contact con : listOfAccountContact){
                       ContactWrapper wrapper = new ContactWrapper();
                       wrapper.id=con.id;
                       wrapper.name=con.name;
                       contactWrapper.add(wrapper);
                   }
               }   
           }
       }
       return contactWrapper;
    }
    
    @RemoteAction
    public static String getDocumentURL(String agrId){
        String agreementId = (String)JSON.deserialize(agrId, String.class);  
        if(agreementId!=null && agreementId!=''){
           return  APTSMD_AgreementPortalConstant.ATTACHMENT_URL+getDocument(agreementId);
        }
        return '';
    }
    
    public static String getDocument(String agreementId){
        if(agreementId!=null && agreementId!=''){
            List<Attachment> listOfAttachment = [SELECT Id,ParentId FROM Attachment WHERE ParentId=:agreementId order by createdDate desc];
            if(listOfAttachment!=null && listOfAttachment.size() > 0){
                Attachment thisAttachment = listOfAttachment[0];
                return  thisAttachment.id;
            }
        }
        return '';
    }
    
    @RemoteAction
    public static String getClauses(String agrId){
        String agreementId = (String)JSON.deserialize(agrId, String.class);  
        AgreementOperationWrapper operationWrapper = new AgreementOperationWrapper();
        Map<String,List<ClauseWrapper>> mapOfCategories = new Map<String,List<ClauseWrapper>>();
        Set<CategoryWrapper> setOfCategory = new Set<CategoryWrapper>();
        if(agreementId!=null && agreementId!=''){
            List<Apttus__APTS_Agreement__c> agreements = [select Id,
                                                                APTSMD_SLA__c,
                                                                Apttus__FF_Agreement_Number__c,
                                                                RecordType.Name,Name,
                                                                //Payment_Terms__c,
                                                                Apttus_CMConfig__PaymentTermId__r.Name,
                                                                APTSMD_Support_Exhibits__c,
                                                                APTSMD_Region__c,
                                                                Apttus__Contract_Start_Date__c,
                                                                Apttus__Contract_End_Date__c 
                                                          from Apttus__APTS_Agreement__c where id=:agreementId];
            if(agreements!=null && agreements.size() > 0){
                Apttus__APTS_Agreement__c agreement = agreements[0];
                String documentId = getDocument(agreementId);
                String recordTypeName = agreement.RecordType.Name+';';
                List<Apttus__APTS_Template__c> clauseList = [SELECT Id,
                                                                    Name,
                                                                    Apttus__TextContent__c,
                                                                    Apttus__Category__c  
                                                            from Apttus__APTS_Template__c 
                                                            where Apttus__Type__c = 'Clause' 
                                                            and Apttus__IsActive__c = True 
                                                            and Apttus__Agreement_Types__c includes (:recordTypeName) 
                                                            order by Apttus__Category__c];
                if(!clauseList.isEmpty()){
                     List<APTSMD_Agreement_Portal_Clause__c> agreementPortalClauses = [select Id,APTSMD_Clause__c 
                                                                                      from APTSMD_Agreement_Portal_Clause__c 
                                                                                      where APTSMD_Related_Agreement__c =:agreement.Id];
                     Map<Id,APTSMD_Agreement_Portal_Clause__c> mapOfAgreementPortalClauses = new Map<Id,APTSMD_Agreement_Portal_Clause__c>();
                     if(agreementPortalClauses!=null && agreementPortalClauses.size() > 0){
                         for(APTSMD_Agreement_Portal_Clause__c clause : agreementPortalClauses){
                            mapOfAgreementPortalClauses.put(clause.APTSMD_Clause__c,clause);
                         }
                     }
                    for(Apttus__APTS_Template__c clause : clauseList){
                        List<ClauseWrapper> listOfClauses = mapOfCategories.get(clause.Apttus__Category__c);
                        if(listOfClauses==null){
                            listOfClauses = new List<ClauseWrapper>();
                        }
                        ClauseWrapper clauseWrapper = new ClauseWrapper();
                        
                        if(mapOfAgreementPortalClauses.get(clause.id)!=null){
                            clauseWrapper.isSelected = true;
                            clauseWrapper.isClauseExpand = false;
                        }else{
                            clauseWrapper.isSelected = false;
                            clauseWrapper.isClauseExpand = true;
                        }
                        clauseWrapper.id = clause.id;
                        clauseWrapper.name = clause.name;
                        clauseWrapper.content = clause.Apttus__TextContent__c;
                        listOfClauses.add(clauseWrapper);
                        mapOfCategories.put(clause.Apttus__Category__c,listOfClauses);
                    }
                    if(mapOfCategories!=null && mapOfCategories.size() > 0){
                        List<AggregateResult> clauseSet = [SELECT Apttus__Category__c  
                                                          from Apttus__APTS_Template__c 
                                                          where Apttus__Type__c = 'Clause' 
                                                          and Apttus__IsActive__c = True 
                                                          and Apttus__Agreement_Types__c includes (:recordTypeName) 
                                                          group by Apttus__Category__c order by Apttus__Category__c ];
                        for(AggregateResult clause : clauseSet){
                            CategoryWrapper wrapper = new CategoryWrapper();
                            wrapper.name = (String)clause.get('Apttus__Category__c');
                            wrapper.isExapnd = true;
                            wrapper.clauses = mapOfCategories.get((String)clause.get('Apttus__Category__c'));
                            setOfCategory.add(wrapper);
                        }
                    }
                }
                List<APTSMD_Agreement_Addendum__c> agreementAddendum = [select Id,APTSMD_Portal_Addendum__c 
                                                                        from APTSMD_Agreement_Addendum__c 
                                                                        where APTSMD_Related_Agreement__c =: agreement.Id];
                Map<Id,APTSMD_Agreement_Addendum__c> mapOfAgreementAddendum = new Map<Id,APTSMD_Agreement_Addendum__c>();
                if(agreementAddendum!=null && agreementAddendum.size() > 0){
                   for(APTSMD_Agreement_Addendum__c addendum : agreementAddendum){
                        mapOfAgreementAddendum.put(addendum.APTSMD_Portal_Addendum__c,addendum);
                    }
                }
                List<APTSMD_Portal_Addendums__c> listOfAddendums = [select Id,Name,APTSMD_Name__c from APTSMD_Portal_Addendums__c];
                List<AddendumWrapper> listOfAddendumsWrapper = new List<AddendumWrapper>();
                if(listOfAddendums!=null && listOfAddendums.size() > 0){
                    for(APTSMD_Portal_Addendums__c addendum : listOfAddendums){
                        AddendumWrapper wrapper = new AddendumWrapper();
                        wrapper.Id= addendum.Id;
                        wrapper.Name= addendum.APTSMD_Name__c;
                        if(mapOfAgreementAddendum.get(addendum.Id)!=null){
                            wrapper.isSelected=true;
                        }else{
                            wrapper.isSelected=false;
                        }
                        listOfAddendumsWrapper.add(wrapper);
                    }
                }
                
                operationWrapper.addendums = listOfAddendumsWrapper;               
                operationWrapper.agreementName = agreement.Name;
                operationWrapper.agreementNumber = agreement.Apttus__FF_Agreement_Number__c;
                operationWrapper.agreementId = agreement.Id;
                operationWrapper.recordTypeName = recordTypeName;
                operationWrapper.attachmentId = documentId;
                //commented by Devangi as logic for payment terms has to be changed
                //operationWrapper.templateFieldTerm = agreement.Payment_Terms__c;
                operationWrapper.templateFieldTerm = agreement.Apttus_CMConfig__PaymentTermId__r.Name;
                operationWrapper.templateFieldRegion = agreement.APTSMD_Region__c;
                operationWrapper.templateFieldSupport = agreement.APTSMD_Support_Exhibits__c;
                operationWrapper.templateFieldSLA = agreement.APTSMD_SLA__c;
                operationWrapper.templateFieldStartDate = convertDateTimeToDate(agreement.Apttus__Contract_Start_Date__c);
                operationWrapper.templateFieldEndDate  = convertDateTimeToDate(agreement.Apttus__Contract_End_Date__c);
                operationWrapper.templateFieldStartYear = String.valueOf(agreement.Apttus__Contract_Start_Date__c.year());
                operationWrapper.templateFieldStartMonth = String.valueOf(agreement.Apttus__Contract_Start_Date__c.month());
                operationWrapper.templateFieldStartDay = String.valueOf(agreement.Apttus__Contract_Start_Date__c.day());
                operationWrapper.templateFieldEndYear = String.valueOf(agreement.Apttus__Contract_End_Date__c.year());
                operationWrapper.templateFieldEndMonth = String.valueOf(agreement.Apttus__Contract_End_Date__c.month());
                operationWrapper.templateFieldEndDay = String.valueOf(agreement.Apttus__Contract_End_Date__c.day());
                operationWrapper.templateURL = APTSMD_AgreementPortalConstant.ATTACHMENT_URL+documentId;
                operationWrapper.clauseCategories = setOfCategory;
            }
        }
        return JSON.serialize(operationWrapper);
    }
    
    @RemoteAction
    public static String createAgreement(String agreementDataJson){
       AgreementData agreement = (AgreementData)JSON.deserialize(agreementDataJson,AgreementData.class);   
        if(agreement!=null){
            //Query Payment Term Id
            List<Apttus_Config2__PaymentTerm__c> paymentTermList = [SELECT Id,
                                                                           Name,
                                                                           Apttus_Config2__Label__c
                                                                    FROM Apttus_Config2__PaymentTerm__c
                                                                    WHERE Name =: agreement.term];
            Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
            agr.Name=agreement.name;
            agr.Apttus__Account__c=agreement.accountData.Id;
            agr.Apttus__Company_Signed_By__c=agreement.contactData.Id;
            agr.Apttus__Primary_Contact__c = agreement.contactData.Id;
            agr.OwnerId=APTSMD_AgreementPortalConstant.portalOwner.Id;
            agr.APTSMD_Region__c = agreement.region;
            if(agreement.agreementConfidentiality=='No' && agreement.mainAgreement=='Yes'){
                agr.RecordTypeID=APTSMD_AgreementPortalConstant.msaRecordType.Id;
                //agr.Payment_Terms__c = agreement.term;
                agr.Apttus_CMConfig__PaymentTermId__c = paymentTermList[0].Id;
                agr.APTSMD_Support_Exhibits__c = agreement.support;
                if(agreement.agreementTotalValue!=''){
                    agr.Apttus__Total_Contract_Value__c = Decimal.valueOf(agreement.agreementTotalValue);
                }
            }else{
                agr.RecordTypeID=APTSMD_AgreementPortalConstant.ndaRecordType.id;
                agr.APTSMD_What_is_being_disclosed__c = agreement.agreementBeingDisclosed;
            }
            agr.Apttus__Contract_Start_Date__c=convertDateTimeToDate(agreement.startDate);
            agr.Apttus__Contract_End_Date__c=convertDateTimeToDate(agreement.endDate);
            Database.insert(agr);
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            Database.insert(agr,dlo);
             
            agr.Apttus__Status_Category__c = APTSMD_AgreementPortalConstant.AgreementStatusCategory;
            agr.Apttus__Status__c=APTSMD_AgreementPortalConstant.AgreementStatus;
            update agr;
            return agr.Id;
            
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    @RemoteAction
    public static String saveOrPreviewDocument(String agreementDataJson){
       AgreementOperationWrapper templateFields = (AgreementOperationWrapper)JSON.deserialize(agreementDataJson,AgreementOperationWrapper.class);  
       if(templateFields!=null){ 
            List<Apttus__APTS_Agreement__c> listOfAgreement = [select Id,
                                                                      APTSMD_SLA__c,
                                                                      //Payment_Terms__c,
                                                                      //Support_Exhibits1__c,
                                                                      Apttus_CMConfig__PaymentTermId__r.Name,
                                                                      APTSMD_Support_Exhibits__c,
                                                                      APTSMD_Region__c,
                                                                      Apttus__Contract_Start_Date__c,
                                                                      Apttus__Contract_End_Date__c 
                                                              from Apttus__APTS_Agreement__c 
                                                              where Id=:templateFields.agreementId];
                                                              
            //Query Payment Term Id
            List<Apttus_Config2__PaymentTerm__c> paymentTermList = [SELECT Id,
                                                                           Name,
                                                                           Apttus_Config2__Label__c
                                                                    FROM Apttus_Config2__PaymentTerm__c
                                                                    WHERE Name =:templateFields.templateFieldTerm];
            if(listOfAgreement!=null && listOfAgreement.size() > 0){
                Apttus__APTS_Agreement__c agr = listOfAgreement[0];
                if(templateFields.templateFieldTerm!=null){
                    //agr.Payment_Terms__c = templateFields.templateFieldTerm;
                    agr.Apttus_CMConfig__PaymentTermId__c = paymentTermList[0].Id;
                }
                if(templateFields.templateFieldSupport!=null){
                    agr.APTSMD_Support_Exhibits__c = templateFields.templateFieldSupport;
                    //agr.Support_Exhibits1__c = templateFields.templateFieldSupport;
                }
                if(templateFields.templateFieldStartDate!=null){
                    agr.Apttus__Contract_Start_Date__c=convertDateTimeToDate(templateFields.templateFieldStartDate);
                }
                if(templateFields.templateFieldEndDate!=null){
                    agr.Apttus__Contract_End_Date__c=convertDateTimeToDate(templateFields.templateFieldEndDate);
                }
                if(templateFields.templateFieldRegion!=null){
                    agr.APTSMD_Region__c = templateFields.templateFieldRegion;
                }
                if(templateFields.templateFieldSLA!=null){
                    agr.APTSMD_SLA__c = templateFields.templateFieldSLA;
                }
                if(templateFields.addendums!=null && templateFields.addendums.size() > 0){
                    List<APTSMD_Agreement_Addendum__c> listToDelete = [select Id 
                                                                      from APTSMD_Agreement_Addendum__c 
                                                                      where APTSMD_Related_Agreement__c =: agr.Id];
                    if(listToDelete!=null && listToDelete.size() > 0){
                        delete listToDelete;
                    }
                    List<APTSMD_Agreement_Addendum__c> listOfAddendum = new List<APTSMD_Agreement_Addendum__c>();
                    for(AddendumWrapper addendum : templateFields.addendums){
                        if(addendum.isSelected){
                            APTSMD_Agreement_Addendum__c agrAddendum = new APTSMD_Agreement_Addendum__c();
                            agrAddendum.APTSMD_Related_Agreement__c = agr.Id;
                            agrAddendum.APTSMD_Name__c = addendum.name;
                            agrAddendum.APTSMD_Portal_Addendum__c = addendum.Id;
                            listOfAddendum.add(agrAddendum);
                        }
                    }
                    if(listOfAddendum!=null && listOfAddendum.size() > 0){
                        insert listOfAddendum;
                    }
                }
                if(templateFields.clauseCategories!=null && templateFields.clauseCategories.size() > 0){
                    List<APTSMD_Agreement_Portal_Clause__c> listToDelete = [select Id 
                                                                            from APTSMD_Agreement_Portal_Clause__c 
                                                                            where APTSMD_Related_Agreement__c =: agr.Id];
                    if(listToDelete!=null && listToDelete.size() > 0){
                        delete listToDelete;
                    }
                    List<APTSMD_Agreement_Portal_Clause__c> listOfPortalClauses = new List<APTSMD_Agreement_Portal_Clause__c>();
                    for(CategoryWrapper category : templateFields.clauseCategories){
                        if(category.clauses!=null && category.clauses.size() > 0){
                            for(ClauseWrapper wrapper : category.clauses){
                                if(wrapper.isSelected){    
                                    APTSMD_Agreement_Portal_Clause__c clause = new APTSMD_Agreement_Portal_Clause__c();
                                    clause.APTSMD_Clause_Text__c = wrapper.content;
                                    clause.APTSMD_Related_Agreement__c = agr.Id;
                                    clause.APTSMD_Clause__c = wrapper.Id;
                                    listOfPortalClauses.add(clause);
                                }
                            }
                        }
                    }
                    if(listOfPortalClauses!=null && listOfPortalClauses.size() > 0){
                        insert listOfPortalClauses;
                    }
                }
                update agr;
                return agr.id;
            }    
       }
       return null;
    }
    @RemoteAction
    public static String generateDocument(String id){
        String agreementId = (String)JSON.deserialize(id,String.class);   
        if(agreementId!=null){
            List<Apttus__APTS_Agreement__c> listOfAgreement = [select Id,RecordType.DeveloperName from Apttus__APTS_Agreement__c where Id=:agreementId];
            if(listOfAgreement!=null && listOfAgreement.size() > 0){
                Apttus__APTS_Agreement__c agreement = listOfAgreement[0];
                String sessionID = UserInfo.getSessionId();
                Apttus__APTS_Template__c template;
                if(agreement.RecordType.DeveloperName==APTSMD_AgreementPortalConstant.NDA_RECORD_TYPE_NAME){
                    template = getTemplateByName(APTSMD_AgreementPortalConstant.NDA_TEMPLATE_NAME);
                }else{
                    template = getTemplateByName(APTSMD_AgreementPortalConstant.MSA_TEMPLATE_NAME);
                }
                if(template!=null){
                    APTSMD_GenerateDocument.generateDocument(template.Id,agreement.Id, sessionID);
                    return APTSMD_AgreementPortalConstant.SUCCESS;
                }
            }
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    @RemoteAction
    public static String generateDocumentAndUpdateStatus(String id,String operation){
        String agreementId = (String)JSON.deserialize(id,String.class);   
        String operationType = (String)JSON.deserialize(operation,String.class);   
        if(agreementId!=null && operation!=null){
            List<Apttus__APTS_Agreement__c> listOfAgreement = [select Id,RecordType.DeveloperName from Apttus__APTS_Agreement__c where Id=:agreementId];
            if(listOfAgreement!=null && listOfAgreement.size() > 0){
                Apttus__APTS_Agreement__c agreement = listOfAgreement[0];
                String sessionID = UserInfo.getSessionId();
                Apttus__APTS_Template__c template;
                if(agreement.RecordType.DeveloperName==APTSMD_AgreementPortalConstant.NDA_RECORD_TYPE_NAME){
                    template = getTemplateByName(APTSMD_AgreementPortalConstant.NDA_TEMPLATE_NAME);
                }else{
                    template = getTemplateByName(APTSMD_AgreementPortalConstant.MSA_TEMPLATE_NAME);
                }
                if(template!=null){
                    String docId = APTSMD_GenerateDocument.generateDocument(template.Id,agreement.Id, sessionID);
                    if(operationType=='Preview'){
                      List<Attachment> listOfAttachment = [select Id,Description from Attachment where Id = :docId];
                      List<Attachment> listOfAttachmentToUpdate = new List<Attachment>();
                      if(listOfAttachment!=null && listOfAttachment.size() > 0){
                          for (Attachment att : listOfAttachment){
                             att.Description='Delete';
                             listOfAttachmentToUpdate.add(att);
                          }
                          if(listOfAttachmentToUpdate!=null && listOfAttachmentToUpdate.size() > 0){
                            update listOfAttachmentToUpdate;    
                          }
                      }
                    }
                    return APTSMD_AgreementPortalConstant.SUCCESS;
                }
            }
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    @RemoteAction
    public static String createNDA(String id){
        String portalUserID = (String)JSON.deserialize(id,String.class);   
        if(portalUserID!=null){
            List<APTSMD_Portal_Agreement_Request__c> listOfPortalAgreementRequest = [select Id,
                                                                                            APTSMD_Portal_Agreement_Request_Name__c,
                                                                                            APTSMD_Agreement_Name__c,Name,
                                                                                            APTSMD_Account_Name__c,
                                                                                            APTSMD_City__c,
                                                                                            APTSMD_Email_Address__c,
                                                                                            APTSMD_isVerified__c,
                                                                                            APTSMD_NDA_Start_Date__c,
                                                                                            APTSMD_Phone_Number__c,
                                                                                            APTSMD_Primary_Contact_Name__c,
                                                                                            APTSMD_Primary_Email_Address__c,
                                                                                            APTSMD_State__c,
                                                                                            APTSMD_Street__c,
                                                                                            APTSMD_What_is_being_disclosed__c,
                                                                                            APTSMD_Zip__c 
                                                                                    from APTSMD_Portal_Agreement_Request__c 
                                                                                    where Id =: portalUserID.trim() 
                                                                                    and APTSMD_isVerified__c = false 
                                                                                    and APTSMD_isVerificationLinkExpire__c = false];
            if(listOfPortalAgreementRequest!=null && listOfPortalAgreementRequest.size() > 0){
                APTSMD_Portal_Agreement_Request__c  portalRequest = listOfPortalAgreementRequest[0];
                portalRequest.APTSMD_isVerified__c = true;
                update portalRequest;
                Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
                agr.Name=portalRequest.APTSMD_Agreement_Name__c;
                agr.Apttus__Account__c=APTSMD_AgreementPortalConstant.account.Id;
                agr.RecordTypeID=APTSMD_AgreementPortalConstant.ndaRecordType.id;
                agr.Apttus__Contract_Start_Date__c=portalRequest.APTSMD_NDA_Start_Date__c;
                agr.APTSMD_What_is_being_disclosed__c=portalRequest.APTSMD_What_is_being_disclosed__c;
                agr.OwnerId=APTSMD_AgreementPortalConstant.portalOwner.Id;
                agr.APTSMD_Portal_Agreement_Request__c=portalRequest.Id;
                agr.APTSMD_PortalAgmntPrimaryCont__c = portalRequest.APTSMD_Primary_Contact_Name__c;
                agr.APTSMD_Portal_Agreement_Request_Email__c = portalRequest.APTSMD_Email_Address__c;
                agr.APTSMD_Portal_Agreement_Request_Name__c = portalRequest.APTSMD_Portal_Agreement_Request_Name__c;
                insert agr;
                agr.Apttus__Status_Category__c = APTSMD_AgreementPortalConstant.AgreementStatusCategory;
                agr.Apttus__Status__c=APTSMD_AgreementPortalConstant.AgreementStatus;
                update agr;
                return APTSMD_AgreementPortalConstant.SUCCESS;
            }
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    @RemoteAction
    public static String verify(String email){
        String emailAddress = (String)JSON.deserialize(email,String.class);   
        if(emailAddress!=null && emailAddress!=''){
            List<APTSMD_Portal_Employee__c> listOfPortalEmp = [select Id,
                                                                      APTSMD_Email_Address__c 
                                                               from APTSMD_Portal_Employee__c 
                                                               where APTSMD_Email_Address__c =:emailAddress ];
            if(listOfPortalEmp!=null && listOfPortalEmp.size() > 0){
                return APTSMD_AgreementPortalConstant.SUCCESS;
            }else{
                return APTSMD_AgreementPortalConstant.Fail;
            }
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    
    @RemoteAction
    public static String sendForESignaure(String agreementId,String documentId){
        String agrId = (String)JSON.deserialize(agreementId,String.class);   
        String docId = (String)JSON.deserialize(documentId,String.class);   
        if(agrId!=null && agrId!='' && docId!=null && docId!=''){
            List<Apttus__APTS_Agreement__c> listOfAgreement = [Select Id,
                                                                      Apttus__Status__c, 
                                                                      Name, 
                                                                      Apttus__Primary_Contact__c, 
                                                                      Apttus__Account__c 
                                                              from Apttus__APTS_Agreement__c 
                                                              where id = :agrId limit 1];
            if(listOfAgreement!=null && listOfAgreement.size() > 0){
                Apttus__APTS_Agreement__c agreement = listOfAgreement[0];
                boolean isSuccess = APTSMD_GenerateDocument.sendToEchoSign(docId,agreement.Id,agreement.Name,agreement.Apttus__Primary_Contact__c);
                if(isSuccess){
                    agreement.Apttus__Status__c='Other Party Signatures';
                    update agreement;
                    return APTSMD_AgreementPortalConstant.SUCCESS;
                }else{
                    return APTSMD_AgreementPortalConstant.Fail;
                }
            }
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    
    @RemoteAction
    public static String sendForReview(String agreementId,String documentId){
        String agrId = (String)JSON.deserialize(agreementId,String.class);   
        String docId = (String)JSON.deserialize(documentId,String.class);   
        if(agrId!=null && agrId!='' && docId!=null && docId!=''){
            List<Apttus__APTS_Agreement__c> listOfAgreement = [Select Id,
                                                                      Apttus__Status__c, 
                                                                      Name, 
                                                                      Apttus__Primary_Contact__c, 
                                                                      Apttus__Account__c 
                                                              from Apttus__APTS_Agreement__c 
                                                              where id = :agrId limit 1];
            if(listOfAgreement!=null && listOfAgreement.size() > 0){
                Apttus__APTS_Agreement__c agreement = listOfAgreement[0];
                if(APTSMD_AgreementPortalConstant.contact != null && APTSMD_AgreementPortalConstant.reviewEmailTemplate != null){
                      List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                      List<Attachment> listOfAttachment = [select Name, Body, BodyLength from Attachment where Id = :docId];
                      if(listOfAttachment!=null && listOfAttachment.size() > 0){
                          for (Attachment att : listOfAttachment){
                              Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                              efa.setFileName(att.Name);
                              efa.setBody(att.Body);
                              fileAttachments.add(efa);
                          }
                      }
                      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                      mail.setToAddresses(new String[]{} );
                      mail.setSaveAsActivity(false);
                      mail.setTargetObjectId(agreement.Apttus__Primary_Contact__c);
                      mail.setTemplateId(APTSMD_AgreementPortalConstant.reviewEmailTemplate.id);
                      mail.setWhatId(agreement.id);
                      mail.setFileAttachments(fileAttachments);
                      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                      return APTSMD_AgreementPortalConstant.SUCCESS;
                  }
            }
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    
    @RemoteAction
    public static String createPortalAgreementRequest(String portalEmpDataJson){
       PortalAgreementRequestWrapper portalRequestWrapper = (PortalAgreementRequestWrapper)JSON.deserialize(portalEmpDataJson,PortalAgreementRequestWrapper.class);   
        if(portalRequestWrapper!=null){
            APTSMD_Portal_Agreement_Request__c portalRequest = new APTSMD_Portal_Agreement_Request__c();
            portalRequest.APTSMD_Portal_Agreement_Request_Name__c = portalRequestWrapper.requesterName;
            portalRequest.APTSMD_Account_Name__c = portalRequestWrapper.accountName;
            portalRequest.APTSMD_City__c = portalRequestWrapper.city;
            portalRequest.APTSMD_Email_Address__c = portalRequestWrapper.requesterEmail;
            portalRequest.APTSMD_NDA_Start_Date__c = convertDateTimeToDate(portalRequestWrapper.ndaStartDate);
            portalRequest.APTSMD_Phone_Number__c = portalRequestWrapper.requesterPhone;
            portalRequest.APTSMD_Primary_Contact_Name__c = portalRequestWrapper.primaryContactName;
            portalRequest.APTSMD_Primary_Email_Address__c = portalRequestWrapper.primaryContactEmail;
            portalRequest.APTSMD_State__c = portalRequestWrapper.state;
            portalRequest.APTSMD_Street__c = portalRequestWrapper.street;
            portalRequest.APTSMD_What_is_being_disclosed__c = portalRequestWrapper.beingDisclosed;
            portalRequest.APTSMD_Zip__c = portalRequestWrapper.zip;   
            portalRequest.APTSMD_Agreement_Name__c = portalRequestWrapper.agreementName;
            portalRequest.APTSMD_Portal_Agreement_Link__c = APTSMD_AgreementPortalConstant.COMMUNITY_URL;
            insert portalRequest;
            try{
                if(portalRequest!=null){
                      String[] toEmail = new String[]{ portalRequest.APTSMD_Email_Address__c }; 
                      if(APTSMD_AgreementPortalConstant.contact != null && APTSMD_AgreementPortalConstant.emailTemplate != null){
                          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                          mail.setToAddresses(toEmail );
                          mail.setSaveAsActivity(false);
                          mail.setTargetObjectId(APTSMD_AgreementPortalConstant.contact.Id);
                          mail.setTemplateId(APTSMD_AgreementPortalConstant.emailTemplate.id);
                          mail.setWhatId(portalRequest.id);
                          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                      }
                }
            }catch(Exception e){
                system.debug(e);                
            }
             return APTSMD_AgreementPortalConstant.SUCCESS;
        }
        return APTSMD_AgreementPortalConstant.Fail;
    }
    public static Date convertDateTimeToDate(DateTime dt){
        if(dt==null){
            return null;
        }
        return Date.valueOf(dt);
        //return  date.newinstance(dt.year(), dt.month(), dt.day());
    }
    public static Date convertDateTimeToDateForDisplay(DateTime dt){
        if(dt==null){
            System.now().date();
        }
        return  dt.date();
    }
    
    public static Apttus__APTS_Template__c getTemplateByName(String templateName){
        return [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name =:templateName LIMIT 1];
    }
    class AgreementData {
        String name {get;set;}
        AccountWrapper accountData {get;set;}
        ContactWrapper contactData {get;set;}
        String agreementConfidentiality {get;set;}
        String region {get;set;}
        String agreementBeingDisclosed {get;set;}
        String term {get;set;}
        String support {get;set;}
        String agreementTotalValue {get;set;}
        String mainAgreement {get;set;}
        DateTime startDate {get;set;}
        DateTime endDate {get;set;}
    }
    
    class ContactWrapper {
        String id {get;set;}
        String name {get;set;}
    }
    
    class AccountWrapper {
        String id {get;set;}
        String name {get;set;}
    }
    
    class KeyValueWrapper {
        String label {get;set;}
        String value {get;set;}
    }
    
    class AccountAndContactWrapper {
        String firstName {get;set;}
        String lastName {get;set;}
        String email {get;set;}
        String phone {get;set;}
        String passwordData {get;set;}
    }
    class AgreementWrapper {
        Integer srNo {get;set;}
        String agreementId {get;set;}
        String agreementName {get;set;}
        String accountId {get;set;}
        String accountName {get;set;}
        String category {get;set;}
        String status {get;set;}
        String primaryContact {get;set;}
        Date startDate {get;set;}
        Date endDate {get;set;}
        DateTime createdDate {get;set;}
        String agreementNumber {get;set;}
        String recordTypeName {get;set;}
        Decimal contractValue {get;set;}
    }
    
    class PortalAgreementRequestWrapper{
          String accountName {get;set;}
          String street {get;set;}
          String city {get;set;}
          String state {get;set;}
          Decimal zip {get;set;}
          String primaryContactName {get;set;}
          String primaryContactEmail {get;set;}
          String requesterName {get;set;}
          String beingDisclosed {get;set;}
          DateTime ndaStartDate {get;set;}
          String requesterEmail {get;set;}
          String requesterPhone {get;set;}
          String agreementName {get;set;}
    }
    
    class AgreementOperationWrapper {
       String agreementName {get;set;}
       String agreementNumber {get;set;}
       String templateURL {get;set;}
       String attachmentId {get;set;}
       String agreementId {get;set;}
       String templateFieldTerm {get;set;}
       String templateFieldRegion {get;set;}
       String templateFieldSupport {get;set;}
       Boolean templateFieldSLA {get;set;}
       DateTime templateFieldStartDate {get;set;}
       DateTime templateFieldEndDate {get;set;}
       String templateFieldStartYear {get;set;}
       String templateFieldStartMonth {get;set;}
       String templateFieldStartDay {get;set;}
       String templateFieldEndYear {get;set;}
       String templateFieldEndMonth {get;set;}
       String templateFieldEndDay {get;set;}
       Set<CategoryWrapper> clauseCategories {get;set;}
       List<AddendumWrapper> addendums {get;set;} 
       String recordTypeName {get;set;}
    }
    
    class ClauseWrapper{
       Boolean isClauseExpand {get;set;}
       Boolean isSelected {get;set;}
       String id {get;set;}
       String name {get;set;} 
       String content {get;set;} 
    }
    
    class AddendumWrapper {
       String id {get;set;}
       String name {get;set;} 
       Boolean isSelected {get;set;}
    }
    
    class CategoryWrapper {
        Boolean isExapnd {get;set;}
        String name {get;set;}
        List<ClauseWrapper> clauses {get;set;}
    }
}