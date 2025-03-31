/*
    We are using this class to display Invoice Detail on a VF page.
    @Author : Chetan Meghnathi
    Date : 01/01/2019
*/
public class APTSMD_InvoicePageController {
    public string invoiceID {get;set;}
    public Apttus_Billing__Invoice__c invoice{get; set;}
    
    public String email{get;set;}
    public String attachmentId{get;set;}
    
    public APTSMD_InvoicePageController (ApexPages.StandardController stdController) {
        invoiceID = ApexPages.currentPage().getParameters().get('id');
        
        invoice = [Select Name,APTSMD_Credit_Amount__c,APTSMD_Total_Payment_Amount__c, Apttus_Billing__TotalFeeAmount__c, Apttus_Billing__TotalTaxAmount__c, 
                    Apttus_Billing__BillToAccountId__r.AccountNumber, Apttus_Billing__BillToAccountId__c, 
                    Apttus_Billing__InvoiceDate__c, Apttus_Billing__DueDate__c,Apttus_Billing__Invoice__c.Apttus_Billing__BillToAccountId__r.Phone,
                    Apttus_Billing__TotalInvoiceAmount__c, Apttus_Billing__TotalDueAmount__c, Apttus_Billing__TotalDiscountAmount__c,
                    Apttus_Billing__Invoice__c.Apttus_Billing__BillToAccountId__r.Name,Apttus_Billing__BillingStreet__c, 
                    Apttus_Billing__BillingCity__c,Apttus_Billing__BillingCountry__c,Apttus_Billing__BillingPostalCode__c,
                    Apttus_Billing__TotalOneTimeFeeAmount__c,Apttus_Billing__TotalRecurringFeeAmount__c,Apttus_Billing__TotalUsageFeeAmount__c, 
                    Apttus_Billing__DaysOutstanding__c, Apttus_Billing__Status__c,Apttus_Billing__DeliveryStatus__c,Apttus_Billing__PaymentStatus__c,
                   	Apttus_Billing__TotalAdditionalFeeAmount__c
                    FROM Apttus_Billing__Invoice__c 
                    WHERE id=: invoiceID limit 1 ];
                    
        /*
            Code to get the email Id of primary contact
        */                   
        List<Contact> contactList = [SELECT Name,email 
                    FROM Contact
                    WHERE AccountId =: invoice.Apttus_Billing__BillToAccountId__c
                    ORDER BY APTSMD_Is_Primary_Contact__c 
                    DESC];   
        if(!contactList.isEmpty()){
            email = contactList[0].email;
        }                    
        else{
            //fetch default primary contact from presales config settings
            APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting = [SELECT APTSMD_Default_Primary_Contact__c 
                    FROM APTSMD_Apttus_PreSales_Config_Settings2__c];
        
            //get contact which matches the name with the value in the custom setting
            Contact matchedContact = [SELECT id,name,email 
                    FROM Contact 
                    WHERE name =: presalesSetting.APTSMD_Default_Primary_Contact__c];
            if(matchedContact!=null && matchedContact.email!=null){
                email = matchedContact.email;
            }
            else{
                email = 'apttussigner@apttus.com';
            }
        }
        /* Code to get email id of primary contact ends here */
        
        /*
            Code to get the Latest Attachment of the Invoice
        */
        List<ContentDocumentLink> listContentDocLink = [select ContentDocumentId,ContentDocument.Title,ContentDocument.ContentModifiedDate, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Apttus_Billing__Invoice__c where Id = :invoiceId  ) ORDER BY SystemModstamp DESC];
        
        if(!listContentDocLink.isEmpty())
        {
            attachmentId = listContentDocLink[0].ContentDocumentId;
        }                 
        /* Code to get Latest Attachment ends here */
    }
}