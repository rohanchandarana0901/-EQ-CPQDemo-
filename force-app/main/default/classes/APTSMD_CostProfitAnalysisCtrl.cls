public class APTSMD_CostProfitAnalysisCtrl {
    public String lineItemSummaryJSON{get;set;}
    public String shipToOptions{get;set;}
    public String materialOptions{get;set;}
    public String industryCodeOptions{get;set;}
    public String countryOptions{get;set;}
    public String incotermOptions{get;set;}
    public String minPrice{get;set;}
    public String maxPrice{get;set;}
    public String minQty{get;set;}
    public String maxQty{get;set;}
    
    public APTSMD_CostProfitAnalysisCtrl(){
        populateOptions();
    }
    
    public void init(){
    
          
    }
    
    public void populateOptions(){
        List<AggregateResult> materialSet = [SELECT APTSMD_Material_Name_and_Code__c materialNameCode 
										     FROM APTSMD_Historical_Line_Item__c 
											 WHERE APTSMD_Comment__c='v4' GROUP BY APTSMD_Material_Name_and_Code__c ORDER BY APTSMD_Material_Name_and_Code__c];
        List<AggregateResult> shipToSet = [SELECT APTSMD_Custom_Name_Code__c shipToNameCode 
										   FROM APTSMD_Historical_Line_Item__c 
										   WHERE APTSMD_Comment__c='v4' GROUP BY APTSMD_Custom_Name_Code__c ORDER BY APTSMD_Custom_Name_Code__c];
        List<AggregateResult> industryCodeSet = [SELECT APTSMD_Industry_Code__c industryCode 
												 FROM APTSMD_Historical_Line_Item__c 
												 WHERE APTSMD_Comment__c='v4' GROUP BY APTSMD_Industry_Code__c ORDER BY APTSMD_Industry_Code__c];
        List<AggregateResult> countrySet = [SELECT APTSMD_Country__c country 
											FROM APTSMD_Historical_Line_Item__c 
											WHERE APTSMD_Comment__c='v4' GROUP BY APTSMD_Country__c ORDER BY APTSMD_Country__c];
        List<AggregateResult> incotermSet = [SELECT APTSMD_IncoTerms__c incoterm 
										     FROM APTSMD_Historical_Line_Item__c 
											 WHERE APTSMD_Comment__c='v4' GROUP BY APTSMD_IncoTerms__c ORDER BY APTSMD_IncoTerms__c];
        
        List<String> materialOptionsLst = new List<String>();
        List<String> shipToOptionsLst = new List<String>();
        List<String> inudtryCodeToOptionsLst = new List<String>();
        List<String> countryOptionsLst = new List<String>();
        List<String> incotermOptionsLst = new List<String>();
        
        for(AggregateResult line : materialSet){
            materialOptionsLst.add((String)line.get('materialNameCode'));
        }
        for(AggregateResult line : shipToSet){
            shipToOptionsLst.add((String)line.get('shipToNameCode'));
        }
        for(AggregateResult line : industryCodeSet){
            String industryCodeStr = (String)line.get('industryCode');
            if(industryCodeStr!=null && industryCodeStr!='')
                inudtryCodeToOptionsLst.add(industryCodeStr);
        }
        for(AggregateResult line : countrySet){
            countryOptionsLst.add((String)line.get('country'));
        }
        for(AggregateResult line : incotermSet){
            incotermOptionsLst.add((String)line.get('incoterm'));
        }
        
        shipToOptions = JSON.serialize(shipToOptionsLst);
        materialOptions =  JSON.serialize(materialOptionsLst); 
        industryCodeOptions =  JSON.serialize(inudtryCodeToOptionsLst); 
        countryOptions =  JSON.serialize(countryOptionsLst); 
        incotermOptions =  JSON.serialize(incotermOptionsLst); 
        
        List<AggregateResult> minMaxResult = [SELECT  max(APTSMD_Apttus_Price__c) maxPrice, min(APTSMD_Apttus_Price__c) minPrice,max(APTSMD_Apttus_Quantity__c) maxQty, min(APTSMD_Apttus_Quantity__c) minQty 
											  FROM APTSMD_Historical_Line_Item__c  
											  WHERE APTSMD_Comment__c='v4' AND APTSMD_Ship_To_Name__c='138330004' group by APTSMD_Comment__c];
        if(!minMaxResult.isEmpty()){
            minPrice = String.valueOf(minMaxResult.get(0).get('minPrice'));
            maxPrice = String.valueOf(minMaxResult.get(0).get('maxPrice'));
            
            minQty = String.valueOf(minMaxResult.get(0).get('minQty'));
            maxQty = String.valueOf(minMaxResult.get(0).get('maxQty'));
        }
    }
    //
    @RemoteAction
    public static List<HistoricalDataWrapper> getData(String materialNo, String lookBack){
        List<HistoricalDataWrapper> lst =  getHistoricData(materialNo,lookBack);
        return lst;
    }
    
     @RemoteAction
    public static List<HistoricalDataWrapper> getSummaryData(String materialNo, String lookBack){
        List<HistoricalDataWrapper> lst =  getHistoricSummaryData(materialNo,lookBack);
        return lst;
    }
    
    @RemoteAction
    public static List<Object> getAnnualVolume(String shipToName){
        List<Object> result = new List<Object>();
        Decimal annualVolume = 0;
        List<APTSMD_Historical_Line_Item__c> lst =  [SELECT ID, APTSMD_Annual_Volume__c, APTSMD_Delivery_Priority__c 
													FROM APTSMD_Historical_Line_Item__c 
													WHERE APTSMD_Ship_To_Name__c = :shipToName];
        if(!lst.isEmpty()){
            result.add(lst.get(0).APTSMD_Annual_Volume__c);
            result.add(lst.get(0).APTSMD_Delivery_Priority__c);
        }
        return result;
    }
    
    
    public static Date getCompareDate(String lookBack){
        Date compareDate;
        Date currentDate = System.today();
        if(lookBack==null || lookBack=='' || lookBack == 'Any'){
            compareDate =  Date.newInstance(1980, 1, 1);
        }
        else if('998'.equalsIgnoreCase(lookBack)){
            compareDate = Date.newInstance(currentDate.year(),currentDate.month(),1);
        }
        else if('999'.equalsIgnoreCase(lookBack)){
            compareDate = Date.newInstance(currentDate.year(),1,1);
        }
        else{
            Integer days = Integer.valueOf(lookBack);
            compareDate =  System.today().addDays(-days);
        }
        
        return compareDate;
    }
    public static List<HistoricalDataWrapper> getHistoricData(String materialNo, String lookBack){
        
        List<HistoricalDataWrapper> resultList = new List<HistoricalDataWrapper>();
        Date compareDate = getCompareDate(lookBack);
        List<APTSMD_Historical_Line_Item__c> dataLst = [SELECT Name, APTSMD_Industry_Code__c, APTSMD_Country__c, APTSMD_IncoTerms__c, APTSMD_Annual_Volume__c, APTSMD_Delivery_Priority__c,
                                                               APTSMD_Sales_Org__c, APTSMD_Plant__c, APTSMD_Ship_To_Name__c, APTSMD_Ship_To_Code__c, APTSMD_Material_Number__c,
														       APTSMD_Apttus_Quantity__c, APTSMD_Apttus_Price__c, APTSMD_Price_Date__c, APTSMD_Margin__c, APTSMD_Binning_Volume__c
                                                        FROM APTSMD_Historical_Line_Item__c 
														WHERE  APTSMD_Comment__c='v4' AND APTSMD_Price_Currency__c ='EUR' AND APTSMD_Price_UoM__c = 'KG' 
														AND APTSMD_Material_Number__c=:materialNo AND APTSMD_Price_Date__c >= :compareDate];
        for(APTSMD_Historical_Line_Item__c lineItem : dataLst){
            resultList.add(convertVO(lineItem));
        }
        
        return resultList;
    }   
    
    public static List<HistoricalDataWrapper> getHistoricSummaryData(String materialNo, String lookBack){
        
        List<HistoricalDataWrapper> resultList = new List<HistoricalDataWrapper>();
        HistoricalDataWrapper newHistoricalData = null;
        Date compareDate = getCompareDate(lookBack);
        List<APTSMD_Historical_Summary_Line_Item__c> dataLst = [SELECT ID, Name, APTSMD_Material_Code__c, APTSMD_Dimension_1__c, APTSMD_Dimension_2__c, APTSMD_Comment__c, APTSMD_Customer_Code__c,
															    APTSMD_Sales_Org__c, APTSMD_Industry_Code__c, APTSMD_Country__c, APTSMD_IncoTerms__c, APTSMD_Price_Date__c
                                                        FROM APTSMD_Historical_Summary_Line_Item__c WHERE APTSMD_Dimension_1__c!=NULL AND  APTSMD_Material_Code__c=:materialNo AND APTSMD_Price_Date__c >= :compareDate]; //AND APTSMD_Price_Date__c >= :compareDate
        for(APTSMD_Historical_Summary_Line_Item__c summaryLineSO : dataLst){
            newHistoricalData = new HistoricalDataWrapper();
            newHistoricalData.dimension1 = summaryLineSO.APTSMD_Dimension_1__c;
            newHistoricalData.dimension2 = summaryLineSO.APTSMD_Dimension_2__c;
            newHistoricalData.materialNo = summaryLineSO.APTSMD_Material_Code__c;
            newHistoricalData.shipToName = summaryLineSO.APTSMD_Customer_Code__c;
            newHistoricalData.salesOrg = summaryLineSO.APTSMD_Sales_Org__c;
            newHistoricalData.industryCode = summaryLineSO.APTSMD_Industry_Code__c;
            newHistoricalData.country = summaryLineSO.APTSMD_Country__c;
            newHistoricalData.incoterm = summaryLineSO.APTSMD_IncoTerms__c;
            newHistoricalData.get();
            resultList.add(newHistoricalData);
        }
        return resultList;
    }   
    public static  HistoricalDataWrapper convertVO(APTSMD_Historical_Line_Item__c lineItem){
        HistoricalDataWrapper historyLineItem = null;
        
        if(lineItem!=null){
            historyLineItem = new HistoricalDataWrapper();
            historyLineItem.salesOrg = lineItem.APTSMD_Sales_Org__c;
            historyLineItem.plant = lineItem.APTSMD_Plant__c;
            historyLineItem.shipToName = lineItem.APTSMD_Ship_To_Name__c;
            historyLineItem.shipToCode = lineItem.APTSMD_Ship_To_Code__c;
            historyLineItem.materialNo = lineItem.APTSMD_Material_Number__c;
            historyLineItem.quantity = lineItem.APTSMD_Apttus_Quantity__c;
            historyLineItem.price = lineItem.APTSMD_Apttus_Price__c;
            historyLineItem.priceDateMain = lineItem.APTSMD_Price_Date__c;
            historyLineItem.margin = lineItem.APTSMD_Margin__c;
            historyLineItem.binningQuantity = lineItem.APTSMD_Binning_Volume__c;
            historyLineItem.annualVolume = lineItem.APTSMD_Annual_Volume__c;
            historyLineItem.deliveryPriority = lineItem.APTSMD_Delivery_Priority__c;
            historyLineItem.industryCode = lineItem.APTSMD_Industry_Code__c;
            historyLineItem.country = lineItem.APTSMD_Country__c;
            historyLineItem.incoterm = lineItem.APTSMD_IncoTerms__c;
            
            
            
            historyLineItem.get();
        }
        
        return historyLineItem;
    }
    
    public class HistoricalDataWrapper{
            public String  salesOrg{get;set;}
            public String  plant{get;set;}
            public String  shipToName{get;set;}
            public String  shipToCode{get;set;}
            public String  materialNo{get;set;}
            public Decimal  quantity{get;set;}
            public Decimal  price{get;set;}
            public Decimal  margin{get;set;}
            public Date     priceDateMain{get;set;}
            public String priceDate{get;set;}
            public Decimal  binningQuantity{get;set;}
            public Decimal  annualVolume{get;set;}
            public String industryCode{get;set;}
            public String country{get;set;}
            public String incoterm{get;set;}
            public String deliveryPriority{get;set;}
            public Decimal  dimension1{get;set;}
            public Decimal  dimension2{get;set;}
            
            public void get(){
                if(priceDateMain!=null){
                    String dateStr = priceDateMain.format();
                    String[] dateArr = dateStr.split('/');
                    this.priceDate = dateArr[1] + '-'+ dateArr[0] + '-'+dateArr[2];
                }
               // return this;
            }
        }
        
    
}