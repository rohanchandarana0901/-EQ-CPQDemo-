/**
* Apttus Digital Commerce
*
* This class is responsible for providing constant values to the payment classes 
*
* @2019 Apttus Inc. All rights reserved.
*/
public with sharing class APTS_PaymentConstants {
    // Transaction Type
    public static final String SALE_CAPTURE = 'sale,create_payment_token';
    public static final String SALE= 'sale';
    
    // Final String literals for Processing Payments
    public final static string BILLING_STATUS_ACTIVE = 'Active';
    public final static string BILLING_STATUS_INACTIVE = 'Inactive';
    public final static string PAYMENT_METHOD_TYPE_CREDITCARD = 'Credit Card';
    public final static string PAYMENT_STATUS_NEW = 'New';
    public final static string BILLING_TRANSACTION_TYPE_PAYMENTCAPTURE = 'Payment Capture';
    public final static string BILLING_TYPE_CREDIT = 'Credit';
    public final static string BILLING_TYPE_STANDARD = 'Standard';
   
    // Final String literals for Processing Gateway Transaction & Communication
    public final static string GATEWAY_COMMUNICATION_PAYLOAD_TYPE_REQUEST = 'Request';
    public final static string GATEWAY_COMMUNICATION_PAYLOAD_TYPE_RESPONSE = 'Response';
    public final static string GATEWAY_COMMUNICATION_TRANSACTION_TYPE_DESC='Payment Create Response';
    public final static string GATEWAY_TRANSACTION_DECISION_PENDING = 'Pending';
    public final static Map<String, String> CARD_TYPE = new Map<String, String>{
                                                                                    '001' => 'Visa', 
                                                                                    '002' => 'Mastercard',
                                                                                    '003' => 'Amex',
                                                                                    '004' => 'Discover',
                                                                                    '005' => 'Diners'
                                                                                 };            
    public static Map<String, String> GATEWAY_TRANSACTION_STATUS = new Map<String, String> {                                                                                        'ACCEPT' => 'Success', 
                                                                                        'REVIEW' => 'Failure',
                                                                                        'CANCEL' => 'Cancelled',
                                                                                        'ERROR' => 'Error',
                                                                                        'DECLINE' => 'Failure',
                                                                                        'ACCEPT' => 'Success'
                                                                                    };            
        
    public static final String GATEWAY_TRANSACTION_STATUS_CHECK='Success';
    public static final String GATEWAY_TRANSACTION_EXCEPTION_STATUS='Error';    
    public static final String PAYMENT_Billing_PaymentStatus_Applied='Applied';   
    
    // CyberSource REMOTE DISPATCHER
    public static final String PAYMENT_DEFAULT_AMOUNT='100'; 
    public static final string CYBERSOURCE_PROFILE_SETTING = Label.cyberSource_Active_CustomSetting;
    public static final string CYBERSOURCE_SILENT_PROFILE_SETTING =Label.cyberSource_Active_Silent_CustomSetting;
    public static final Map<String, String> CYBERSOURCE_TRANSACTION_TYPE = new Map<String, String>{
        'SaleCapture' => 'sale,create_payment_token', 
        'Sale' => 'sale',
        'SilentSale' => 'sale'
        };            
            
    // CyberSource Endpoints
    public static final String Get_PaymentRequest_Details = 'GetPaymentRequestDetails';
    public static final String Get_SilentPaymentRequest_Details = 'GetSilentPaymentRequestDetails';
 
}