global class APTSMD_AgreementWrapper {
  public Boolean isSelected {get;set;}
    public Apttus__APTS_Agreement__c agr{get;set;}        
    public APTSMD_AgreementWrapper(Apttus__APTS_Agreement__c agr, Boolean isSelected)
    {
        this.agr= agr;
        this.isSelected= isSelected;
    }
}