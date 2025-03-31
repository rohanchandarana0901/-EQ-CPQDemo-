trigger APTSMD_SetInvoiceTemplateOnAccount on Account (before insert) {
    List<Account> accountList = Trigger.New;
    APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
    if(!accountList.isEmpty()){
        for (Account account : accountList ) {
           account.Apttus_Config2__DefaultInvoiceTemplate__c = presalesSetting.APTSMD_Default_Invoice_Template__c;
           account.Apttus_Config2__DefaultCreditMemoTemplate__c = presalesSetting.APTSMD_Default_Credit_Memo_Template__c;
           account.Apttus_Config2__DefaultInvoiceStatementTemplate__c = presalesSetting.APTSMD_Default_InvoiceStatement_Template__c;
           account.Apttus_Config2__CreditMemoEmailTemplate__c = presalesSetting.APTSMD_Credit_Memo_Email_Template__c;
           account.Apttus_Config2__InvoiceEmailTemplate__c = presalesSetting.APTSMD_Default_Invoice_Email_Template__c;
           account.Apttus_Billing__PaymentEmailTemplate__c = presalesSetting.APTSMD_Payment_Email_Template__c;
        }  
    }
  
}