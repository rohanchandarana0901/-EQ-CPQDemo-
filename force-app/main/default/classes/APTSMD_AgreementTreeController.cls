public without sharing class APTSMD_AgreementTreeController {
    Public Apttus__APTS_Agreement__c CurrentAgreement{get; set;}
    Public boolean isError{get; set;}
     private static List<String> amdrenRelTypeList = new List<String>();
  private static final String RTYPE_IS_AMENDMENT_FOR = 'Is Amendment For';  
  private static final String RTYPE_IS_AMENDED_BY = 'Is Amended By';
  private static final String RTYPE_IS_RENEWAL_FOR = 'Is Renewal For';
  private static final String RTYPE_IS_RENEWED_BY = 'Is Renewed By';
  
  private static final String RELATED_FROM = 'Related From';
  private static final String RELATED_TO = 'Related To';
  
  private ApexPages.StandardController controller;
  private String retURL = null;

  
  public ID gotoAgmtId {get; set;}
  
  private Integer lvl = 0;
  public Apttus__APTS_Agreement__c agmt = null;  
  private Map<ID, String> recTypeMap = new Map<ID, String>();
  private Map<String, String> relTextMap = new Map<String, String>();
  
  public List<APTSMD_AgreementTreeWrapper> agmtList {get; private set;}
  private Set<ID> agmtIdList = new Set<ID>();
  
  public String filterField {get; set;}
  public String filterValue {get; set;}
  public List<Selectoption> filterFields {get; private set;}
  public List<Selectoption> filterValues {get; private set;}
  private Map<String, String> statusCategoryMap = new Map<String, String>();
  
  // Code added by japan bhavsar on 12/27/2018
  public List<APTSMD_AgreementTreeWrapper> mainCopyOfAgreementTreeList {get;set;}
  
  //variables for custom search
  public SelectOption[] selectedSearchFields { get; set; }
  public SelectOption[] allSearchFields { get; set; }
  
  public APTSMD_AgreementTreeController(ApexPages.StandardController stdController) {   
        controller = stdController;    
      agmt = (Apttus__APTS_Agreement__c)controller.getRecord(); 
      currentagreement = (Apttus__APTS_Agreement__c)controller.getRecord(); 
    retURL = ApexPages.currentPage().getParameters().get('retURL');   
        init();
    }
    private void init() {
        //set up custom search variables
        selectedSearchFields = new List<SelectOption>();
        allSearchFields = new List<SelectOption>();
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            string fieldLabel = fieldDescribe.getLabel();
            if(filterSearchFields(fieldDescribe))
            {
                allSearchFields.add(new SelectOption(fieldName, fieldLabel));
            }
        }
        allSearchFields.sort();
        //end custom search set up
        
      agmt = APTSMD_AgreementTreeQueryHelper.getAgreement(agmt.Id);

    // related (amend renew) relationship
    amdrenRelTypeList.add(RTYPE_IS_AMENDMENT_FOR);
    amdrenRelTypeList.add(RTYPE_IS_AMENDED_BY);
    amdrenRelTypeList.add(RTYPE_IS_RENEWAL_FOR);
    amdrenRelTypeList.add(RTYPE_IS_RENEWED_BY);
    
    recTypeMap = APTSMD_AgreementTreeWrapper.getRecTypeMap();
    
    filterFields = new List<Selectoption>();
    filterFields.add(new SelectOption('none', '--None--'));
    filterFields.add(new SelectOption('type', 'Type'));
    filterFields.add(new SelectOption('status_category', 'Status Category'));
    filterField = 'none';
    
    filterValues = new List<Selectoption>();
    filterValues.add(new SelectOption('none', '--None--'));
    
        Schema.DescribeFieldResult fldDesc = Apttus__APTS_Agreement__c.Apttus__Status_Category__c.getDescribe();
        List<Schema.PicklistEntry> valueList = fldDesc.getPicklistValues();
        if (valueList != null) {
            for (Schema.PicklistEntry entry : valueList) {     
                statusCategoryMap.put(entry.getValue(), entry.getLabel());  
            }
        }
    }
    public void doLoad() {
    
      agmtList = new List<APTSMD_AgreementTreeWrapper>();
      
      ID primordialId = agmt.APTSMD_Primordial_Agreement__c;
      if (primordialId == null) {
        primordialId = agmt.Id;
      } else {
        agmt = APTSMD_AgreementTreeQueryHelper.getAgreement(primordialId);
      }
            List<Apttus__APTS_Agreement__c> ListOfAgreement = new List<Apttus__APTS_Agreement__c>();
            ListOfAgreement = [Select Id, Apttus__Agreement_Number__c,Name,Apttus__Contract_Start_Date__c,APTSMD_SLA__c,
                               Apttus__Contract_End_Date__c,Apttus__Total_Contract_Value__c,
                               Apttus__Auto_Renewal__c,Apttus__Internal_Renewal_Notification_Days__c,
                               Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, Apttus__Primary_Contact__c, Apttus__Account__c,Apttus__Parent_Agreement__c,Apttus__Version_Number__c,Apttus__Status__c 
                               From Apttus__APTS_Agreement__c  where Apttus__Agreement_Number__c =: agmt.Apttus__Agreement_Number__c OR Apttus__Parent_Agreement__c =: agmt.Id ORDER BY Apttus__Parent_Agreement__c,Apttus__FF_Agreement_Number__c];
            for(Apttus__APTS_Agreement__c agg:ListOfAgreement){
                integer temp =  0;
                if(agg.Apttus__Agreement_Number__c == agmt.Apttus__Agreement_Number__c && agg.Apttus__Version_Number__c>0){
                    temp=1;
                }
                if(agg.Apttus__Parent_Agreement__c != null){ //for CHild Agreement
                        temp=1;
                }
                if(agg.Apttus__Parent_Agreement__c!=null){
                    agmtlist.add(new APTSMD_AgreementTreeWrapper(agg, lvl + temp,'Is Child Of'));
                }else if(agg.Apttus__Agreement_Number__c==agmt.Apttus__Agreement_Number__c && agg.Apttus__Version_Number__c>0){
                    agmtlist.add(new APTSMD_AgreementTreeWrapper(agg, lvl + temp,'Is Amended By'));
                }else{
                    agmtlist.add(new APTSMD_AgreementTreeWrapper(agg, lvl + temp));
                }
                
            }  
        // Copy agmtList to mainCopyOfAgreementTreeList
        mainCopyOfAgreementTreeList = agmtList.clone();        
    }
    public PageReference viewAgmt() {
    return (new PageReference('/' + gotoAgmtId));          
    }
    public PageReference doDone() {
      if (retURL != null) {
      return (new PageReference(retURL));  
      }
    return (new PageReference('/' + agmt.Id));        
    }
    public void doFilter() {
      agmtIdList.clear();
      agmtList = new List<APTSMD_AgreementTreeWrapper>();
      agmt = APTSMD_AgreementTreeQueryHelper.getAgreement(agmt.Id);
      lvl = 0;
      doLoad();        
    }
    
    public void doSetFilterValues() {
      filterValues.clear();
    filterValues.add(new SelectOption('none', '--None--'));
      if  (filterField == 'type') {
      for (ID recId : recTypeMap.keySet()) {
        filterValues.add(new SelectOption(recId, recTypeMap.get(recId)));
      }
    } else if (filterField == 'status_category') {
      for (String val : statusCategoryMap.keySet()) {
        filterValues.add(new SelectOption(val, statusCategoryMap.get(val)));
      }
    }
    }
    public ID getChildren(ID parentId, Integer lvl) {
            
      List<Apttus__APTS_Agreement__c> agList = APTSMD_AgreementTreeQueryHelper.getAgreements(
                APTSMD_AgreementTreeQueryHelper.getChildAgmtIdList(parentId));
      lvl ++; 
      ID agreementN;
      for (Apttus__APTS_Agreement__c ag : agList) {
        if (!agmtIdList.contains(ag.Id)) {
          if (include(ag)) {
            agmtList.add(new APTSMD_AgreementTreeWrapper(ag, lvl));
            agmtIdList.add(ag.Id);
          }
          getRelatedAgmts(ag, lvl);
          getAmendRenewals(ag, lvl);
          getChildren(ag.Id, lvl);
          agreementN = ag.Id;
        }
      }  
        return agreementN;
    }
    public List<Apttus__APTS_Agreement__c> getRelatedAgmts(Apttus__APTS_Agreement__c ag, Integer lvl) {
      List<Apttus__APTS_Related_Agreement__c> relRefs = getRelateAgmtRefs(ag.Id);
      return getRelationshipAgmts(relRefs, ag.Id, lvl);
    }
    public List<Apttus__APTS_Agreement__c> getAmendRenewals(Apttus__APTS_Agreement__c ag, Integer lvl) {
      List<Apttus__APTS_Related_Agreement__c> relRefs = getAmendRenewAgmtRefs(ag.Id);
      return getRelationshipAgmts(relRefs, ag.Id, lvl);     
    }
    private List<Apttus__APTS_Related_Agreement__c> getRelateAgmtRefs(Id agmtId) {
      return [SELECT Id
          , Apttus__APTS_Contract_To__c
          , Apttus__APTS_Contract_From__c
          , Apttus__Relationship_From_Type__c
          , Apttus__Relationship_To_Type__c
          FROM Apttus__APTS_Related_Agreement__c
          WHERE (Apttus__APTS_Contract_From__c = :agmtId
          OR Apttus__APTS_Contract_To__c = :agmtId)
          AND (Apttus__Relationship_To_Type__c NOT IN :amdrenRelTypeList
            OR Apttus__Relationship_From_Type__c NOT IN :amdrenRelTypeList)];
    }
    private List<Apttus__APTS_Related_Agreement__c> getAmendRenewAgmtRefs(Id agmtId) {
      return [SELECT Id
          , Apttus__APTS_Contract_To__c
          , Apttus__APTS_Contract_From__c
          , Apttus__Relationship_From_Type__c
          , Apttus__Relationship_To_Type__c
          FROM Apttus__APTS_Related_Agreement__c
          WHERE (Apttus__APTS_Contract_From__c = :agmtId)
          AND (Apttus__Relationship_To_Type__c IN :amdrenRelTypeList
            OR Apttus__Relationship_From_Type__c IN :amdrenRelTypeList)];
    }
    
    //get relationship agreements
    private List<Apttus__APTS_Agreement__c> getRelationshipAgmts(List<Apttus__APTS_Related_Agreement__c> relRefs, ID agmtId, Integer lvl) {  
    List<ID> idList = new List<ID>();
    List<Apttus__APTS_Agreement__c> relateAgmtList;
      Map<ID, Apttus__APTS_Related_Agreement__c> relationshipMap = 
              new Map<ID, Apttus__APTS_Related_Agreement__c>();   
      
    if ((relRefs != null) && (!relRefs.isEmpty())) {
        for (Apttus__APTS_Related_Agreement__c relRef : relRefs) {
          if (relRef.Apttus__APTS_Contract_To__c == agmtId) {
            idList.add(relRef.Apttus__APTS_Contract_From__c);
            relationshipMap.put(relRef.Apttus__APTS_Contract_From__c, relRef);
          } else {
            idList.add(relRef.Apttus__APTS_Contract_To__c);
            relationshipMap.put(relRef.Apttus__APTS_Contract_To__c, relRef);  
          }
        }  
        String relationship = '';
        relateAgmtList = APTSMD_AgreementTreeQueryHelper.getAgreements(idList);
        for (Apttus__APTS_Agreement__c relateAgmt : relateAgmtList) {
          Apttus__APTS_Related_Agreement__c rel = relationshipMap.get(relateAgmt.Id);
          if (rel.Apttus__APTS_Contract_To__c == agmtId) {
          relationship = rel.Apttus__Relationship_To_Type__c;
          } else {
          relationship = rel.Apttus__Relationship_From_Type__c;  
          }
          if (!agmtIdList.contains(relateAgmt.Id)) {
            if (include(relateAgmt)) {
              agmtList.add(new APTSMD_AgreementTreeWrapper(relateAgmt, lvl, relationship));
              agmtIdList.add(relateAgmt.Id);
            }
          }
        }  
    }
        return relateAgmtList;
    }
    private Boolean include(Apttus__APTS_Agreement__c agmt) {
      if ((filterField == 'none') || (filterValue == 'none')) {
        return true;
      }
      if (filterField == 'type') {
        ID recId = filterValue;
        if (agmt.RecordTypeId == recId) {
          return true;
        } else {
          return false;
        }
      }
      if (filterField == 'status_category') {
        if (agmt.Apttus__Status_Category__c == filterValue) {
          return true;
        } else {
          return false;
        }
      }
      return true;
    }
 // --------------------------------------------------------------------------------------------   
    //search filter methods -- ARRAUL

    private Boolean filterSearchFields(Schema.DescribeFieldResult fieldDescribe)
    {
        string fieldLabel = fieldDescribe.getLabel();
        if(fieldDescribe.isAccessible() && fieldDescribe.isNillable() && !fieldLabel.contains('(OBSOLETE)') && !fieldLabel.contains('(INTERNAL)'))
        {
            //accepted field names
            if(fieldLabel.equalsIgnoreCase('Status')||fieldLabel.equalsIgnoreCase('Status Category')||fieldLabel.equalsIgnoreCase('Agreement Number')
            ||fieldLabel.equalsIgnoreCase('Agreement Start Date')||fieldLabel.equalsIgnoreCase('Agreement End Date')
            ||fieldLabel.equalsIgnoreCase('Parent Agreement'))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }
    } 
    
    // New function added by Japan Bhavsar on 12/27/2018 - start
    
    // doFilterAgreementList() - Filter Logic function
    public void doFilterAgreementList(){
        system.debug(filterField);
        system.debug(filterValue);
        system.debug(statusCategoryMap);
        // check for selection list
        if(filterField == 'none'){
            agmtList = mainCopyOfAgreementTreeList.clone();
        }else{
            if(filterValue != 'none'){
                agmtList.clear();
                if(filterField == 'type'){
                    for(APTSMD_AgreementTreeWrapper temp: mainCopyOfAgreementTreeList){
                        if(temp.agmtType == recTypeMap.get(filterValue)){
                            agmtList.add(temp);
                        }
                    }
                }else{
                    for(APTSMD_AgreementTreeWrapper temp: mainCopyOfAgreementTreeList){
                        if(temp.agreement.Apttus__Status_Category__c == statusCategoryMap.get(filterValue)){
                            agmtList.add(temp);
                        }
                    }
                }
            }else{
            }
        }
    }
    
    // doClearFilter() - Do clear the value of filter inputs
    public void doClearFilter(){
        filterField = 'none';
        filterValue = 'none';
        doFilterAgreementList();
    }
    // New function added by Japan Bhavsar on 12/27/2018 - end
}