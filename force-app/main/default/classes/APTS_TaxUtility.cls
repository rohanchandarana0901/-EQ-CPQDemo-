public class APTS_TaxUtility {
    public static List<Apttus_Config2.CustomClass.TaxResult> lineItemTaxEngine( List<Apttus_Config2.CustomClass.TaxInput> inputs) {

        List<Apttus_Config2.CustomClass.TaxResult> results = new List<Apttus_Config2.CustomClass.TaxResult>();
         for(Apttus_Config2.CustomClass.TaxInput input:inputs){
             Apttus_Config2.CustomClass.TaxResult result = new Apttus_Config2.CustomClass.TaxResult();
             TaxRateModel taxRates = getAvalaraValue(input.TaxAddress);
             System.debug(taxRates);
             
             Decimal totalRate = taxRates.totalRate != null && taxRates.totalRate < 0?taxRates.totalRate:APTS_TaxConstants.TAX_RATE_DEFAULT;
             TaxResulthandBack taxResulthandBackObj = new TaxResulthandBack();
             if(null != input.item) {
                taxResulthandBackObj.lineItem = input.item;
                taxResulthandBackObj.errorMessage = null;
                
            }
            result.Handback = taxResulthandBackObj;
            result.TaxAmount = input.TaxableAmount ==null ? 0 : input.TaxableAmount * totalRate;
            if(APTS_TaxConstants.CALCULATE_FOR_STATES){
                integer sequence = 0;
                for(TaxRateModel.TaxRate taxRate:taxRates.rates){
                    result.TaxBreakups.add(
                    new Apttus_Config2__TaxBreakup__c(
                        Apttus_Config2__Sequence__c = sequence,
                        Apttus_Config2__LineItemId__c = input.Item.Id,
                        Apttus_Config2__BreakupType__c = 'Detail',
                        Apttus_Config2__TaxType__c =    taxRate.type +' Tax',
                        Apttus_Config2__TaxRate__c = taxRate.rate,
                        Apttus_Config2__TaxAppliesTo__c = APTS_TaxConstants.TAX_APPLIESTO_NET_PRICE,
                        Apttus_Config2__TaxAmount__c = (result.TaxAmount * taxRate.rate)
                    ));
                    sequence++;
                }
            }else{
                result.TaxBreakups.add(
                new Apttus_Config2__TaxBreakup__c(
                    Apttus_Config2__Sequence__c = 1,
                    Apttus_Config2__LineItemId__c = input.Item.Id,
                    Apttus_Config2__BreakupType__c = 'Detail',
                    Apttus_Config2__TaxType__c = 'Country Tax',
                    Apttus_Config2__TaxRate__c = totalRate,
                    Apttus_Config2__TaxAppliesTo__c = APTS_TaxConstants.TAX_APPLIESTO_NET_PRICE,
                    Apttus_Config2__TaxAmount__c = (result.TaxAmount * totalRate)
                ));
            }
            
            
            Decimal aggregateTaxAmount = 0.00;
            for(integer iBreakupCount=0;iBreakupCount<result.TaxBreakups.size();iBreakupCount++) {            
              Apttus_Config2__TaxBreakup__c taxBreakup = result.TaxBreakups.get(iBreakupCount);
              aggregateTaxAmount +=taxBreakup.Apttus_Config2__TaxAmount__c.setScale(APTS_TaxConstants.CURRENCY_DECIAML_PLACES);
            }
            result.TaxAmount =aggregateTaxAmount;
            
            results.add(result);
         }
        System.debug('results ==> '+results);
        return results;
    }
    
    public static TaxRateModel getAvalaraValue(Apttus_Config2.CustomClass.Address address) {
        if(address!=null){
            Map<String, String> mapping = new Map<String, String>{
                'line1' => address.Street,
                'city' => address.City,
                'region' => address.State,
                'postalCode' => address.PostalCode,
                'country' => (address.Country == null) ? 'US' : address.Country
            };
            System.PageReference pageReference = new System.PageReference('');
			pageReference.getParameters().putAll(mapping);
			System.debug(pageReference.getUrl());
            string tempData = callEndPoint('GET','','taxrates/byaddress'+ pageReference.getUrl());
            TaxRateModel taxRateModel = TaxRateModel.parse(tempData);
            return taxRateModel;
        }
       return null;
    }
    
    public void addTaxBreakups(Apttus_Config2.CustomClass.TaxInput input, Apttus_Config2.CustomClass.TaxResult result, Apttus_Config2.CustomClass.Address address, Decimal taxRate){
        String state = (null != input.TaxAddress && null != input.TaxAddress.State) ? input.TaxAddress.State : '';
        
    }
    
  public static string callEndPoint(string methodType,string body, string endPoint){

        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod(methodType);   
        httpRequest.setHeader('Authorization', 'Basic '+convertToBase64());
        httpRequest.setEndpoint(Label.APTS_Avalara_Tax_Integration+'/api/v2/'+endPoint);
          system.debug('Label.APTS_Avalara_Tax_Integration '+httpRequest.getEndpoint());
        if(methodType.toUpperCase() != 'GET'){
            httpRequest.setBody(body);
            httpRequest.setHeader('Content-Type','application/json');
        }
            
        string response = '';
        try {
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest); 
            system.debug('response body==>'+httpResponse.getBody());
            response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()));
        }catch(System.Exception e){
            System.debug('ERROR: '+ e);  
            throw e;  
        }
        return response; 
    }
    
    
    public static string convertToBase64(){
        return EncodingUtil.base64Encode(Blob.valueof(APTS_TaxConstants.ACCOUNT_ID+':'+APTS_TaxConstants.LICENCE_KEY));
    }
    
    public class TaxResulthandBack{
        public sObject lineItem{get;set;}
        public string errorMessage{get;set;}
    } 
}