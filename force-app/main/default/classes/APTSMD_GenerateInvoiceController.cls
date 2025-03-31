public class APTSMD_GenerateInvoiceController{
    
    public Account invoiceAccount{get;set;}
    
    public APTSMD_GenerateInvoiceController(ApexPages.StandardController controller){
        invoiceAccount = new Account();
        invoiceAccount.Apttus_Billing__LastInvoicedDate__c = System.today();
        invoiceAccount.Apttus_Billing__ReadyForInvoiceDate__c = System.today();
    }
    
    Id fetchAccountId = apexpages.currentpage().getparameters().get('id');
    
    public PageReference createInvoice(){
        if(invoiceAccount.Apttus_Billing__LastInvoicedDate__c<invoiceAccount.Apttus_Billing__ReadyForInvoiceDate__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invoice Through Date must be greater than Invoice Date.'));
            return null;
        }
        
        Apttus_Billing.BillingService.createInvoices(new Set<Id>{fetchAccountId}, invoiceAccount.Apttus_Billing__LastInvoicedDate__c, invoiceAccount.Apttus_Billing__ReadyForInvoiceDate__c);
        return new PageReference('/' + fetchAccountId);
    }
}