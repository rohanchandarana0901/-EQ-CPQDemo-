public without sharing class APTSMD_AgreementTreeWrapper {
  public Apttus__APTS_Agreement__c agreement {get; private set;}
  public String indent {get; private set;}
  public String agmtType {get; private set;}
  public String relationship {get; private set;}
  
  private static Map<String, String> relTextMap = new Map<String, String>();
  private static Map<ID, String> recTypeMap = new Map<ID, String>();
  
  static {
    relTextMap.put('Related NDA Is', 'NDA');
    relTextMap.put('Is NDA For', 'NDA');
    relTextMap.put('Is Master Of', 'Master');
    relTextMap.put('Is Child Of', 'Child');
    relTextMap.put('Is Related Contract', 'Related');
    relTextMap.put('Is SOW Of', 'SOW');
    relTextMap.put('Is Amendment For', 'Amendment');
    relTextMap.put('Is Amended By', 'Amendment');
    relTextMap.put('Is Superceded By', 'Superceded');
    relTextMap.put('Is Renewed By', 'Renewal');
    relTextMap.put('Is Renewal For', 'Renewal');
    
    List<RecordType> recList = [select Id, Name from RecordType 
        where SobjectType = 'Apttus__APTS_Agreement__c'];
    for (RecordType rec : recList) {
      recTypeMap.put(rec.Id, rec.Name);
    }
  }
  public static Map<ID, String> getRecTypeMap() {
    return recTypeMap;
  }
  public static ID getRecTypeIdFor(String recTypeName) {
    for (ID id : recTypeMap.keySet()) {
      if (recTypeMap.get(id) == recTypeName) {
        return id;
      }
    }
    return null;
  }
  public APTSMD_AgreementTreeWrapper (Account act, Integer lvl) {
    this.agreement = new Apttus__APTS_Agreement__c();
    this.agmtType = '';
    this.agreement.Apttus__Account__c = act.Id;
    this.agreement.Apttus__Account__r = act;
    this.relationship = '';
    setIndent(lvl);
  }
  public APTSMD_AgreementTreeWrapper (Apttus__APTS_Agreement__c agmt, Integer lvl) {
    this.agreement = agmt;
    this.agmtType = recTypeMap.get(agreement.RecordTypeId);
    this.relationship = '';
    setIndent(lvl);
  }
  public APTSMD_AgreementTreeWrapper (Apttus__APTS_Agreement__c agmt, Integer lvl, String relationship) {
    this(agmt, lvl);
    this.relationship = relTextMap.get(relationship);
    setIndent(lvl);
  }
  public APTSMD_AgreementTreeWrapper (Apttus__APTS_Agreement__c agmt, Integer lvl, Boolean clearAccount) {
    this(agmt, lvl);
    if (clearAccount) {
      agmt.Apttus__Account__c = null;
    }    
    setIndent(lvl);
  }
  private void setIndent(Integer lvl) {
    indent = '';
    
    for (Integer i = 0; i < lvl; i++) {
      indent += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
     
    }
  }
}