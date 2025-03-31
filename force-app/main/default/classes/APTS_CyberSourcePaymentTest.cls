/**
* Apttus Digital Commerce
*
* This class is responsible for testing Cybersource/ payment related classes
*
* @2019 Apttus Inc. All rights reserved.
*/
@isTest(seeAllData=True)
public class APTS_CyberSourcePaymentTest {
	/**
	 * This is a test method to test payment request and response classes
	*/
    @isTest
    static void testPaymentRequest() { 
        Test.startTest();
    	APTS_CyberSourceRestResource paymentRequest= new APTS_CyberSourceRestResource();
      
      	Map<String,String> oPassedParams = new Map<String,String>();
        
        oPassedParams.put('CustomerFirstName','Chintan');
        oPassedParams.put('CustomerLastName','Parikh');
        oPassedParams.put('CustomerEmailAddress','Testing Data');
        oPassedParams.put('CustomerAddressLine1','Testing Data');
        oPassedParams.put('CustomerAddressCity','Testing Data');
        oPassedParams.put('CustomerAddressStateCode','Testing Data');
        oPassedParams.put('CustomerAddressCountryCode','Testing Data');
        oPassedParams.put('CustomerAddressPostalCode','Testing Data');
        oPassedParams.put('CustomerBillingAccountName','Testing Data');        
        oPassedParams.put('Locale','Testing Data');  
        oPassedParams.put('OrderAmount','10');
        oPassedParams.put('Currency','Testing Data');
        Apttus_WebStore.RemoteDispatcher.DispatchResponse silentPaymentRequest= paymentRequest.dispatch(APTS_PaymentConstants.Get_SilentPaymentRequest_Details,oPassedParams);
        Apttus_WebStore.RemoteDispatcher.DispatchResponse paymentRespone= paymentRequest.dispatch(APTS_PaymentConstants.Get_PaymentRequest_Details,oPassedParams);
        Map<String, Object> cObjMap = (Map<String, Object>) JSON.deserializeUntyped(paymentRespone.data);        
       	testPaymentResponse(cObjMap);
        
        Test.stopTest();
     
    }
    
     
	/**
	 * This method is responsible for testing Cybersource respone listner class
	*/
	private static void testPaymentResponse(Map<String,Object> responseRequest) {
    	//As Per Best Practice it is important to instantiate the Rest Context
        Account account = new Account(Name='Behind the Cloud Test');
    	Apttus_Config2__Order__c newOrder = new Apttus_Config2__Order__c();
             
     	// Insert book
     	insert newOrder;
     	insert account;
     	Apttus_Billing__GatewayTransaction__c newTestGatewayTransaction = new Apttus_Billing__GatewayTransaction__c(Apttus_Billing__OrderId__c=newOrder.Id,
                                                                                                                    Apttus_Billing__AccountId__c=account.Id,
                                                                                                                    Apttus_Billing__TransactionId__c=(string)responseRequest.get('transaction_uuid'));
        
        insert newTestGatewayTransaction;
     	system.debug('order response=>' + newOrder.Id);
 	    RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
     	req.addParameter('req_transaction_type', APTS_PaymentConstants.SALE_CAPTURE);
        req.addParameter('message','Testing Data');
        req.addParameter('invalid_fields','Testing Data');      
        req.addParameter('req_merchant_defined_data2','Testing Data');
        req.addParameter('req_reference_number','Testing Data');
        req.addParameter('req_card_number','xxxxxxxxxxx1111');
        req.addParameter('req_card_expiry_date','Testing Data');
        req.addParameter('req_transaction_uuid',newTestGatewayTransaction.Apttus_Billing__TransactionId__c);    
        req.addParameter('decision','ACCEPT');    
        req.addParameter('reason_code','001');
        req.addParameter('req_card_type','Testing Data');       
        req.addParameter('req_bill_to_forename','Testing Data');
        req.addParameter('req_bill_to_surname','Testing Data');
        req.addParameter('payment_token','Testing Data');
        req.addParameter('req_card_expiry_date','12-2022');
        req.addParameter('req_currency','USD');
        req.addParameter('req_profile_id','Testing Data');
        req.addParameter('reason_code','Testing Data');
        req.addParameter('req_amount','100');        
        
        req.requestURI = '/services/apexrest/ResponseExtractor/';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
       
        APTS_CyberSourceResponseRestResource.onPost();   
    }

}