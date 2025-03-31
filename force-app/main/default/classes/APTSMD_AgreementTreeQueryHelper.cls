public without sharing class APTSMD_AgreementTreeQueryHelper {

  private static List<String> amdrenRelTypeList = new List<String>();
  private static String sq = '\'';
  private static Integer maxFetchSize = Limits.getLimitQueryRows();
     
  // relationship types
  private static final String RTYPE_IS_AMENDMENT_FOR = 'Is Amendment For';  
  private static final String RTYPE_IS_AMENDED_BY = 'Is Amended By';
  private static final String RTYPE_IS_RENEWAL_FOR = 'Is Renewal For';
  private static final String RTYPE_IS_RENEWED_BY = 'Is Renewed By';
  
  private APTSMD_AgreementTreeQueryHelper() {
  
  }
  static{
    // related (amend renew) relationship
    //amdrenRelTypeList.add(RTYPE_IS_AMENDMENT_FOR);
    amdrenRelTypeList.add(RTYPE_IS_AMENDED_BY);
    //amdrenRelTypeList.add(RTYPE_IS_RENEWAL_FOR);
    amdrenRelTypeList.add(RTYPE_IS_RENEWED_BY);
  }


    /**
    * Get child agreement id list.
    * @param parentAgmtId id 
    * @return list of ID
    */
    public static List<ID> getChildAgmtIdList(ID parentId) {
      List<Apttus__APTS_Agreement__c> agmtList = [select id from Apttus__APTS_Agreement__c 
          where Apttus__Parent_Agreement__c = :parentId];
          
      List<ID> idList = new List<ID>();    
    if (agmtList != null) {
      for (Apttus__APTS_Agreement__c agmt : agmtList) {
        idList.add(agmt.Id);
      }
    }
    return idList;
    }


    /**
    * Get sibling agreement id list. Exclude context agreement
    * @param ctxAgmtId context agreement id
    * @param parentAgmtId id of the context agreement's parent
    * @return list of ID
    */
    public static List<ID> getSiblingAgmtIdList(ID ctxAgmtId, ID parentId) {
      List<Apttus__APTS_Agreement__c> agmtList = [select id from Apttus__APTS_Agreement__c 
          where Apttus__Parent_Agreement__c = :parentId
          AND id != :ctxAgmtId];
          
      List<ID> idList = new List<ID>();    
    if (agmtList != null) {
      for (Apttus__APTS_Agreement__c agmt : agmtList) {
        idList.add(agmt.Id);
      }
    }
    return idList;
    }  
    /**
    * Gets related agreements id list for the provided context agreement identifier
    * @param ctxAgmtId id of the agreement who's related needs to retrieved
    * @return list of ID
    */
    public static List<ID> getRelatedAgmtIdList(ID ctxAgmtId) {
      List<Apttus__APTS_Related_Agreement__c> relRefs = [SELECT Id
          , Apttus__APTS_Contract_To__c
          , Apttus__APTS_Contract_From__c
          FROM Apttus__APTS_Related_Agreement__c
          WHERE (Apttus__APTS_Contract_From__c = :ctxAgmtId
          OR Apttus__APTS_Contract_To__c = :ctxAgmtId)
          AND (Apttus__Relationship_To_Type__c NOT IN :amdrenRelTypeList
            OR Apttus__Relationship_From_Type__c NOT IN :amdrenRelTypeList)];
           
    List<ID> idList = new List<ID>();
      for (Apttus__APTS_Related_Agreement__c ref : relRefs) {
        if (ref.Apttus__APTS_Contract_To__c == ctxAgmtId) {
          idList.add(ref.Apttus__APTS_Contract_From__c);  
        } else {
          idList.add(ref.Apttus__APTS_Contract_To__c);  
        }
      }  
      return idList;
    }
    
    /**
    * Gets amendment amd renewal agreement id list for the provided context agreement identifier
    * @param ctxAgmtId id of the agreement who's renewals and amendments needs to retrieved
    * @return list of ID
    */
    public static List<ID> getAmendRenewAgmtIdList(ID ctxAgmtId) {
      List<Apttus__APTS_Related_Agreement__c> relRefs = [SELECT Id
          , Apttus__APTS_Contract_To__c
          , Apttus__APTS_Contract_From__c
          FROM Apttus__APTS_Related_Agreement__c
          WHERE (Apttus__APTS_Contract_From__c = :ctxAgmtId
          OR Apttus__APTS_Contract_To__c = :ctxAgmtId)
          AND (Apttus__Relationship_To_Type__c IN :amdrenRelTypeList
            OR Apttus__Relationship_From_Type__c IN :amdrenRelTypeList)];
           
    List<ID> idList = new List<ID>();
      for (Apttus__APTS_Related_Agreement__c ref : relRefs) {
        if (ref.Apttus__APTS_Contract_To__c == ctxAgmtId) {
          idList.add(ref.Apttus__APTS_Contract_From__c);  
        } else {
          idList.add(ref.Apttus__APTS_Contract_To__c);  
        }
      }  
      return idList;
    }
  
  /**
  * Gets agreements for the provided list of agreement identifiers
  * - selects id,name,number,category,status
  * @param ids list of agreement identifiers
  * @return list of agreements
  */
  public static List<Apttus__APTS_Agreement__c> getAgreements(ID[] ids) {  
     String queryString = getQueryStringWithAllFields('Apttus__APTS_Agreement__c','Id IN :ids');
     System.debug('*****'+queryString);
     return Database.query(queryString);  
  }
  
  
  /**
  * Gets agreement for the provided agreement identifiers
  * - selects id,name,number,category,status
  * @param id  agreement identifiers
  * @return agreement
  */
  public static Apttus__APTS_Agreement__c getAgreement(ID id) {  
     String queryString = getQueryStringWithAllFields('Apttus__APTS_Agreement__c','Id=:id');
     System.debug('*****'+queryString);
     List<Apttus__APTS_Agreement__c> agmts = Database.query(queryString);  

    if ((agmts != null) && (!agmts.isEmpty())) {
      return agmts[0];
    }  
    return null;     
  }
  
  
  public static List<Apttus__APTS_Agreement__c> getAccountAgreements(ID actId) {  
      String queryString = getQueryStringWithAllFields('Apttus__APTS_Agreement__c','Apttus__Account__c=:actId');
      System.debug('*****'+queryString);
      return Database.query(queryString);      
  }
  
   //added for agreement tree by account id
  public static List<Apttus__APTS_Agreement__c> getAgreementsByAccount(ID actId) {  
      String queryString = getQueryStringWithAllFields('Apttus__APTS_Agreement__c','Apttus__Account__c=:actId');
      System.debug('*****'+queryString);
      return Database.query(queryString);   
  }
  
   
    public static string getQueryStringWithAllFields(String objectName, String whereClause){
        String selects = '';
     
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            
                    selectFields.add(fd.getName());
               
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        
        if (whereClause != null) {
            selects += ',Apttus__Account__r.Name';
            return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause + ' ORDER by CreatedDate';
        }
        else {
            selects += ',Apttus__Account__r.Name';
            return 'SELECT ' + selects + ' FROM ' + objectName + ' ORDER by CreatedDate';
        }
        
          
    }
}