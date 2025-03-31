/**
* Apttus Digital Commerce
*
* This rest Resource Class is responsible for receving Cybersource response after transaction complete
*
* @2019 Apttus Inc. All rights reserved.
*/
@RestResource(urlMapping='/ResponseExtractor/')
global with sharing class APTS_CyberSourceResponseRestResource {
  
    /**
     * Handles incoming HTTP Post requests from payment gateway
     * @returns to some random location for iframe.
     */
    @HttpPost
    global static Void onPost() {
        
        map<string, string> mapstring = new map<string, string>();
        mapstring = RestContext.request.params;
        
        // fetch callback URL
         APTS_CyberSource_Profile_Details__c cyberSourcePrimarySetting = APTS_CyberSource_Profile_Details__c.getValues('System Properties');
        // fetch query string

        if(mapstring.get('req_transaction_type')==APTS_PaymentConstants.SALE_CAPTURE) {
                createPaymentMethod(mapstring,true);
        }
       else if(mapstring.get('req_transaction_type')==APTS_PaymentConstants.SALE) {
                createPaymentMethod(mapstring,false);
        }
         RestContext.response.statusCode = 302;
         RestContext.response.addHeader('Location', cyberSourcePrimarySetting.PaymentCallbackURL__c);
         RestContext.response.addHeader('http-equiv','refresh');
    
    } 
    

    //This method will create payment method on request of create payment token
    private static void createPaymentMethod(map<string, string> mapstring, boolean isPaymentCapture) {
        boolean isDefault= false;  
        Apttus_Billing__GatewayTransaction__c ExistingGatewayTransaction; 
        Apttus_Billing__PaymentMethod__c oPaymentMethod;
        Apttus_Billing__GatewayCommunication__c oGatewayCommunication;                      

    // Get all the details from Response URL
        string message =  mapstring.get('message');
        string invalid_fields = mapstring.get('invalid_fields');      
        string contactId = mapstring.get('req_merchant_defined_data2');
        string reference_number = mapstring.get('req_reference_number');
        string card_number = mapstring.get('req_card_number');
        string card_expiry = mapstring.get('req_card_expiry_date');
        string transaction_id = mapstring.get('req_transaction_uuid');    
        string decision = mapstring.get('decision');    
        string reason_code = mapstring.get('reason_code');
        string card_type_code = mapstring.get('req_card_type');       
        string paymentMethodName=mapstring.get('req_bill_to_forename') +' '+ mapstring.get('req_bill_to_surname');
        string paymentMethodToken=mapstring.get('payment_token');
        String[] cardExpiryDate = mapstring.get('req_card_expiry_date').splitByCharacterType();
        string requestedCurrency =mapstring.get('req_currency');
        string requestedProfileID =mapstring.get('req_profile_id');
        string responseReasonCode =mapstring.get('reason_code');
        string transactionStatus= APTS_PaymentConstants.GATEWAY_TRANSACTION_STATUS.get(decision);   
        string amount = mapstring.get('req_amount');
        
        Savepoint sp = Database.setSavepoint();  // Rollback to this savepoint in case any exception occurs.        

        oPaymentMethod = new Apttus_Billing__PaymentMethod__c();   
        
        
        ExistingGatewayTransaction = [select Id,Name,Apttus_Billing__AccountId__c,Apttus_Billing__OrderId__c from Apttus_Billing__GatewayTransaction__c where Apttus_Billing__TransactionId__c = :transaction_id limit 1];

         if( ExistingGatewayTransaction != null ) {             
                Apttus_Billing__PaymentMethod__c[] isAnyPaymentExist = [select Id,Name from Apttus_Billing__PaymentMethod__c 
                                          where Apttus_Billing__AccountId__c = :ExistingGatewayTransaction.Apttus_Billing__AccountId__c];

                if(isAnyPaymentExist.size() < 1) {
                    isDefault = true;             
                }             
             
                oPaymentMethod.Apttus_Billing__PaymentMethodName__c = paymentMethodName;
                oPaymentMethod.Apttus_Billing__AccountId__c = ExistingGatewayTransaction.Apttus_Billing__AccountId__c;             
                oPaymentMethod.Apttus_Billing__IsDefault__c = isDefault;
                oPaymentMethod.Apttus_Billing__Status__c= APTS_PaymentConstants.BILLING_STATUS_ACTIVE;
                oPaymentMethod.Apttus_Billing__PaymentMethodType__c = APTS_PaymentConstants.PAYMENT_METHOD_TYPE_CREDITCARD;
                oPaymentMethod.Apttus_Billing__TokenId__c = paymentMethodToken;          
                oPaymentMethod.Apttus_Billing__CardNumber__c =card_number;                    
                oPaymentMethod.Apttus_Billing__CardExpirationMonth__c = cardExpiryDate[0];
                oPaymentMethod.Apttus_Billing__CardExpirationYear__c = cardExpiryDate[2];
                oPaymentMethod.Apttus_Billing__CardType__c = APTS_PaymentConstants.CARD_TYPE.get(card_type_code);
                oPaymentMethod.CurrencyIsoCode = requestedCurrency;
                oPaymentMethod.Apttus_Billing__ProfileId__c = requestedProfileID;


                // Creating the payment object.
                Apttus_Billing__Payment__c oPayment = new Apttus_Billing__Payment__c();
                oPayment.Apttus_Billing__AccountId__c = ExistingGatewayTransaction.Apttus_Billing__AccountId__c;                    
                oPayment.CurrencyIsoCode = requestedCurrency;
                oPayment.Apttus_Billing__PaymentDate__c = Date.today();                
                oPayment.Apttus_Billing__PaymentAmount__c =Decimal.valueOf(amount.replaceAll('[^.\\d]',''));                    
                oPayment.Apttus_Billing__ReasonCode__c = responseReasonCode;
                oPayment.Apttus_Billing__PaymentStatus__c =APTS_PaymentConstants.PAYMENT_Billing_PaymentStatus_Applied;
                oPayment.Apttus_Billing__ReasonDescription__c = message;
                oPayment.Apttus_Billing__OrderId__c = ExistingGatewayTransaction.Apttus_Billing__OrderId__c;
            
                
                oGatewayCommunication= new Apttus_Billing__GatewayCommunication__c();
                oGatewayCommunication.Apttus_Billing__GatewayTransactiontId__c = ExistingGatewayTransaction.Id;  
                oGatewayCommunication.Apttus_Billing__Payload__c =JSON.serialize(mapstring);  
                oGatewayCommunication.Apttus_Billing__PayloadType__c = APTS_PaymentConstants.GATEWAY_COMMUNICATION_PAYLOAD_TYPE_RESPONSE;  
                oGatewayCommunication.Apttus_Billing__CommunicationDate__c = System.now();  
                oGatewayCommunication.Apttus_Billing__Type__c = APTS_PaymentConstants.GATEWAY_COMMUNICATION_TRANSACTION_TYPE_DESC;  
             
             
            try {                      
                
                if(transactionStatus == APTS_PaymentConstants.GATEWAY_TRANSACTION_STATUS_CHECK) {
                oPayment.Apttus_Billing__Status__c = APTS_PaymentConstants.PAYMENT_STATUS_NEW;
                if(isPaymentCapture) {
                    insert oPaymentMethod;
                    ExistingGatewayTransaction.Apttus_Billing__PaymentMethodId__c = oPaymentMethod.Id;
                }

                insert oPayment;
                ExistingGatewayTransaction.Apttus_Billing__PaymentId__c = oPayment.Id;  
                }                      
                                
                ExistingGatewayTransaction.Apttus_Billing__ReasonCode__c = responseReasonCode;
                ExistingGatewayTransaction.Apttus_Billing__ResponseString__c = message;
                ExistingGatewayTransaction.Apttus_Billing__Status__c = transactionStatus;
                update ExistingGatewayTransaction;
                insert oGatewayCommunication;                        
            } catch(Exception ex) {                     
                Database.rollback(sp);                
                oGatewayCommunication= new Apttus_Billing__GatewayCommunication__c();
                oGatewayCommunication.Apttus_Billing__GatewayTransactiontId__c = ExistingGatewayTransaction.Id;  
                oGatewayCommunication.Apttus_Billing__Payload__c =JSON.serialize(mapstring);  
                oGatewayCommunication.Apttus_Billing__PayloadType__c = APTS_PaymentConstants.GATEWAY_COMMUNICATION_PAYLOAD_TYPE_RESPONSE;  
                oGatewayCommunication.Apttus_Billing__CommunicationDate__c = System.now();  
                oGatewayCommunication.Apttus_Billing__Type__c = APTS_PaymentConstants.GATEWAY_COMMUNICATION_TRANSACTION_TYPE_DESC;  
            
                ExistingGatewayTransaction.Apttus_Billing__ReasonCode__c = responseReasonCode;
                ExistingGatewayTransaction.Apttus_Billing__ResponseString__c = ex.getMessage();
                ExistingGatewayTransaction.Apttus_Billing__Status__c = APTS_PaymentConstants.GATEWAY_TRANSACTION_EXCEPTION_STATUS;
                update ExistingGatewayTransaction;
                insert oGatewayCommunication; 
                 system.debug('Exception PYAMENT=>'+ex.getLineNumber() + ':' + ex.getMessage() + '\n' +  ex.getStackTraceString());
            }
            
        }
    }

}