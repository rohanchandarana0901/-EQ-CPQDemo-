@isTest
public class APTS_TaxCallBackTest {
    public static testMethod void computeTaxForCartTest(){        
        // insert ship to account
        Account shipTo = new Account(
                Name = 'shipTo to AccountTest',
                ShippingStreet = '123 Test St',
                ShippingState = 'California',
                ShippingPostalCode = '92615',
                ShippingCity = 'Irvine',
                ShippingCountry = 'United States'
            );
        insert shipTo;
        
        Apttus_Config2__ProductConfiguration__c cart = new Apttus_Config2__ProductConfiguration__c(
                                                            Name = 'Test Cart',
                                                            Apttus_Config2__ShipToAccountId__c = shipTo.Id);
        insert cart;
        Id cartId = cart.Id;      //Product Config - Tax Opportunity
        PageReference pageRef = Page.TaxPOCPage;
        System.Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',cartId);
        APTS_TaxCallBack taxCallBack = new APTS_TaxCallBack();
        taxCallBack.computeTaxForCart();
    }

    public static testMethod void computeTaxTest(){
    
         // insert ship to account
        Account shipTo = new Account(
                Name = 'shipTo to AccountTest',
                ShippingStreet = '123 Test St',
                ShippingState = 'California',
                ShippingPostalCode = '92615',
                ShippingCity = 'Irvine',
                ShippingCountry = 'United States'
            );
        insert shipTo;
        
        Apttus_Config2__ProductConfiguration__c cart = new Apttus_Config2__ProductConfiguration__c(
                                                            Name = 'Test Cart',
                                                            Apttus_Config2__ShipToAccountId__c = shipTo.Id);
                                                            
        insert cart;                                                    
        Id cartId = cart.Id;
        
        Apttus_Config2.CustomClass.Address address = new Apttus_Config2.CustomClass.Address();
        address.Street = '123 Main Street';
        address.City = 'Irvine';
        address.State = 'California';
        address.StateCode = 'CA';
        address.County = '';
        address.PostalCode = '92615';
        address.Country = 'United States';
        address.CountryCode = 'USA';
        
        // create tax code
        Apttus_Config2__TaxCode__c taxCodeSO = new Apttus_Config2__TaxCode__c(
                                    Name = 'SalesTaxCode',
                                    Apttus_Config2__Code__c = 'PC040100',
                                    Apttus_Config2__Description__c = 'Test Sales Tax Code');
        insert taxCodeSO;                          
        
        // create cart line items
        Apttus_Config2__LineItem__c lineitemToInsert = new Apttus_Config2__LineItem__c(
                            Apttus_Config2__LineNumber__c = 1,
                            Apttus_Config2__ItemSequence__c = 1,
                            Apttus_Config2__ConfigurationId__c = cartId ,
                            Apttus_Config2__Taxable__c = TRUE,
                            Apttus_Config2__TaxInclusive__c = FALSE,
                            Apttus_Config2__ShipToAccountId__c = shipTo.Id,
                            Apttus_Config2__TaxCodeId__c = taxCodeSO.Id);
                            
        insert lineitemToInsert;
        
        List<Apttus_Config2__LineItem__c> taxableItems = new List<Apttus_Config2__LineItem__c>();
        taxableItems.add(lineitemToInsert);
        for(Apttus_Config2__LineItem__c lineItemSO : [SELECT Id, Apttus_Config2__TaxInclusive__c, Apttus_Config2__TaxCodeId__c, Apttus_Config2__TaxCodeId__r.Apttus_Config2__Code__c, 
                                                  Apttus_Config2__Taxable__c, Apttus_Config2__ShipToAccountId__c, Apttus_Config2__Quantity__c, Apttus_Config2__ProductId__c, 
                                                  Apttus_Config2__ProductId__r.Name, Apttus_Config2__OptionId__c, Apttus_Config2__OptionId__r.Name, Apttus_Config2__NetPrice__c, 
                                                  Apttus_Config2__LocationId__c, Apttus_Config2__LineNumber__c, Apttus_Config2__LineStatus__c, Apttus_Config2__LineType__c, 
                                                  Apttus_Config2__ListPrice__c, Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__ChargeType__c, 
                                                  Apttus_Config2__BillToAccountId__c, Apttus_Config2__BasePrice__c FROM Apttus_Config2__LineItem__c 
                                                  WHERE Apttus_Config2__ConfigurationId__c = :cartId AND Apttus_Config2__Taxable__c = TRUE AND Apttus_Config2__TaxInclusive__c = FALSE]){
                if (lineItemSO.Apttus_Config2__TaxCodeId__c != null)                    
                    taxableItems.add(lineItemSO);
                                                      
        }
        system.debug('lineitems = '+taxableItems);
        
        List<Apttus_Config2.CustomClass.TaxInput> taxInputs = new List<Apttus_Config2.CustomClass.TaxInput>();
        for (Apttus_Config2__LineItem__c lineItemSO : taxableItems) {
            String taxCode = lineItemSO.Apttus_Config2__TaxCodeId__r.Apttus_Config2__Code__c;
            if (!(taxCode == null || taxCode.trim().length() == 0)) {
                Apttus_Config2.CustomClass.TaxInput input = new Apttus_Config2.CustomClass.TaxInput();
                input.TaxCode = taxCode;
                input.TaxAddress = address;
                input.TaxableAmount = lineItemSO.Apttus_Config2__NetPrice__c;
                input.Item = lineItemSO;
                input.Handback = null;
                taxInputs.add(input);
            }
            
        }
        
        if (!taxInputs.isEmpty()) {
            
            // initiate mock class
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new TaxCallBackMockHttpResponse());
            APTS_TaxCallBack taxCallBack = new APTS_TaxCallBack();
            system.debug('before computeTax');
            taxCallBack.computeTax(taxInputs[0]);
            system.debug('before computeTaxMultiple');
            taxCallBack.computeTaxMultiple(taxInputs);
            Test.StopTest();
            
        }
       
    }
}