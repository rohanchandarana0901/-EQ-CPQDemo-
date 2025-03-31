/**
* Apttus Digital Commerce
*
* This class is responsible for providing Cybersource transaction related details for performing transaction with payment gateway
*
* @2019 Apttus Inc. All rights reserved.
*/
global class APTS_CyberSourceRestResource implements Apttus_WebStore.RemoteDispatcher.DispatchInterface {
  
   global Apttus_WebStore.RemoteDispatcher.DispatchResponse dispatch(String method, Object jsonData) {
        Map<String, Object> data =(Map<String, Object>) jsonData;
        
       try {
           if(method == APTS_PaymentConstants.Get_PaymentRequest_Details) return GetPaymentRequestDetails(data);   
           else if(method == APTS_PaymentConstants.Get_SilentPaymentRequest_Details) return GetSilentPaymentRequestDetails(data);
           else return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(false, 'Invalid Endpoint: ' + method);
           
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(false, e.getLineNumber() + ':' + e.getMessage() + '\n' + method + '\n' + JSON.serialize(jsonData));
        }
    }

    /**This method will provide transaction details for payment method
      * @param data contains transaction related details for creating payment method payload
       * @returns RemoteDispatcher.DispatchResponse instance with JSON response of payload
     */
    private Apttus_WebStore.RemoteDispatcher.DispatchResponse GetPaymentRequestDetails(Map<String, Object> data) {
        Map<String,String> oPassedParams = new Map<String,String>();
        APTS_CyberSource_Profile_Details__c objCyberSource = APTS_CyberSource_Profile_Details__c.getValues(APTS_PaymentConstants.CYBERSOURCE_PROFILE_SETTING);
        oPassedParams.put('bill_to_forename',(String)data.get('CustomerFirstName'));
        oPassedParams.put('bill_to_surname',(String)data.get('CustomerLastName'));
        oPassedParams.put('bill_to_email',(String)data.get('CustomerEmailAddress'));
        oPassedParams.put('bill_to_address_line1',(String)data.get('CustomerAddressLine1'));
        oPassedParams.put('bill_to_address_city',(String)data.get('CustomerAddressCity'));
        oPassedParams.put('bill_to_address_state',(String)data.get('CustomerAddressStateCode'));
        oPassedParams.put('bill_to_address_country',(String)data.get('CustomerAddressCountryCode'));
        oPassedParams.put('bill_to_address_postal_code',(String)data.get('CustomerAddressPostalCode'));
        oPassedParams.put('bill_to_company_name',(String)data.get('CustomerBillingAccountName'));
        oPassedParams.put('access_key',objCyberSource.Access_Key__c);
        oPassedParams.put('profile_id',objCyberSource.Profile_ID__c);
        oPassedParams.put('transaction_uuid',getUUID());
        oPassedParams.put('signed_field_names','access_key,amount,bill_to_address_city,bill_to_address_country,bill_to_address_line1,bill_to_address_postal_code,bill_to_address_state,bill_to_company_name,bill_to_email,bill_to_forename,bill_to_surname,currency,locale,profile_id,reference_number,signed_date_time,signed_field_names,transaction_type,transaction_uuid,unsigned_field_names');
        oPassedParams.put('unsigned_field_names',''); 
        oPassedParams.put('signed_date_time',getUTCDateTime());
        oPassedParams.put('locale',(String)data.get('Locale'));        
        oPassedParams.put('transaction_type',(String)APTS_PaymentConstants.CYBERSOURCE_TRANSACTION_TYPE.get((String)data.get('PaymentType'))); //This is a static value to permform action at Cybersource side.
        oPassedParams.put('reference_number',UserInfo.getUserId());
        string amount=(String)data.get('OrderAmount');
        if(objCyberSource.IsTestEnvironment__c && decimal.valueOf(amount) > decimal.valueOf(APTS_PaymentConstants.PAYMENT_DEFAULT_AMOUNT)){ 
          amount=APTS_PaymentConstants.PAYMENT_DEFAULT_AMOUNT;
        }
        oPassedParams.put('amount',amount);//in the testing environmentit's advisable to set order amount 100
        oPassedParams.put('currency',(String)data.get('Currency'));
        oPassedParams.put('signature',sign(oPassedParams,objCyberSource));        	       	
        oPassedParams.put('IFram_Url__c',objCyberSource.IFram_Url__c);
        
        return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(true, oPassedParams);
    }  

   /**This method is responsible for providing transaction related details to perform final payment against of order
      * @param data contains transaction related details for creating payment payload
       * @returns RemoteDispatcher.DispatchResponse instance with JSON response of payload
   */
   private Apttus_WebStore.RemoteDispatcher.DispatchResponse GetSilentPaymentRequestDetails(Map<String, Object> data) {
        Map<String,String> oPassedParams = new Map<String,String>();
        APTS_CyberSource_Profile_Details__c objCyberSource = APTS_CyberSource_Profile_Details__c.getValues(APTS_PaymentConstants.CYBERSOURCE_SILENT_PROFILE_SETTING);
        oPassedParams.put('access_key',objCyberSource.Access_Key__c);
        oPassedParams.put('profile_id',objCyberSource.Profile_ID__c);
        oPassedParams.put('reference_number',UserInfo.getUserId());
        oPassedParams.put('currency',(String)data.get('Currency'));        		
        string amount=(String)data.get('OrderAmount');
        if(objCyberSource.IsTestEnvironment__c && decimal.valueOf(amount) > decimal.valueOf(APTS_PaymentConstants.PAYMENT_DEFAULT_AMOUNT)){ 
          amount=APTS_PaymentConstants.PAYMENT_DEFAULT_AMOUNT;
        }
        oPassedParams.put('amount',amount);//in the testing environmentit's advisable to set order amount 100
        oPassedParams.put('locale',(String)data.get('Locale'));
        oPassedParams.put('payment_token',(String)data.get('PaymentToken'));
        oPassedParams.put('transaction_uuid',getUUID());
        oPassedParams.put('signed_field_names','access_key,amount,currency,locale,payment_token,profile_id,reference_number,signed_date_time,signed_field_names,transaction_type,transaction_uuid,unsigned_field_names');
        oPassedParams.put('unsigned_field_names',''); 
        oPassedParams.put('signed_date_time',getUTCDateTime());
        oPassedParams.put('transaction_type',(String)APTS_PaymentConstants.CYBERSOURCE_TRANSACTION_TYPE.get((String)data.get('PaymentType')));
        oPassedParams.put('signature',sign(oPassedParams, objCyberSource));        	       	
        oPassedParams.put('IFram_Url__c',objCyberSource.IFram_Url__c);        	     		
       
       
        return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(true, oPassedParams);
    }
    
    //This method will generate a encrypted sign key for transaction between apttus and cybersource
    public static String sign(Map<String, String> paramsArray, APTS_CyberSource_Profile_Details__c objCyberSource)  {
        system.debug('paramsArray=> '+ paramsArray);
        String result = sign(buildDataToSign(paramsArray), recover(objCyberSource));
        return result;
    }
     
     //This method will get current UTC time
    public static String getUTCDateTime() {
        system.debug('Current UTC time=> '+ System.now());
        DateTime oUTSDateTime = System.now();
         system.debug('oUTSDateTime UTC time=> '+ oUTSDateTime);
        String strUTCDateTime = oUTSDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', UserInfo.getTimeZone().getDisplayName());
         system.debug('strUTCDateTime UTC time=> '+ strUTCDateTime);
        return strUTCDateTime;
    }    
    
    //This method will provide cybersource secret key which is stored in two seprate fields
    private static String recover(APTS_CyberSource_Profile_Details__c objCyberSource) {
           return objCyberSource.Secret_Key1__c+objCyberSource.Secret_Key2__c; 
		}
    
    //separating fields by comma
    private static String commaSeparate(List<String> dataToSign) {
        String result = '';
        for(String str : dataToSign) {
            result += (result==''?'':',') + str;
        }
        return result;                         
    }
    
    //Building signed field for all required fields by Cybersource
    private static String buildDataToSign(Map<String,String> paramsArray) {
        String[] signedFieldNames = paramsArray.get('signed_field_names').split(',');
        List<String> dataToSign = new List<String>();
        
        for(String oSignedFieldName : signedFieldNames) {
            dataToSign.add(oSignedFieldName + '=' + paramsArray.get(oSignedFieldName));
        }
        return commaSeparate(dataToSign);
    }
    
    //This method will generate a encrypted sign key for transaction between apttus and cybersource
    private static String sign(String data, String secretKey) {
        String result = EncodingUtil.base64Encode(Crypto.generateMac('hmacSHA256', Blob.valueOf(data), Blob.valueOf(secretKey)));
        return result;
    }

    
    //Get Unique ID for transaction
    public static String getUUID() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String guid = h.substring(0,8) + '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);        
        return guid;
    }  
}