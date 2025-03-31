/*
 * Created BY - JAPAN Bhavsar
 * Purpose - to create product information record for Digital commerce product images
 * 
 * */

public class APTSMD_CreateProductInfomration {
	public static void createProductInformation(string priceListId){
        if(priceListId == null){
            return;
        }
        // Fetch all the Products
        Map<Id,Product2> productsMap = new Map<Id,Product2>([SELECT Id, Name, Apttus_Config2__IconId__c
                        FROM Product2 
                        WHERE Id IN (SELECT Apttus_Config2__ProductId__c FROM Apttus_Config2__PriceListItem__c WHERE Apttus_Config2__PriceListId__c = :priceListId)]);
        if(!productsMap.isEmpty()){
            List<Attachment> attachments = new List<Attachment>();
            attachments = [SELECT Body, BodyLength, ContentType, Description, 
                                Name, ParentId
                                FROM Attachment
                                WHERE ParentId IN :productsMap.keySet()];
            Map<Id,Attachment> mapOfParentIdVsAttachment = new Map<Id,Attachment>();
            if(!attachments.isEmpty()){
                for(Attachment att : attachments){
                    // Create map of parent id and attachment
                    mapOfParentIdVsAttachment.put(att.ParentId, att);
                }
                System.debug('mapOfParentIdVsAttachment >>' + mapOfParentIdVsAttachment);
                List<Apttus_Config2__ProductInformation__c> prodInfoToInsert = new List<Apttus_Config2__ProductInformation__c>();
                for(Product2 prod : productsMap.values()){
                    prodInfoToInsert.add(new Apttus_Config2__ProductInformation__c(
                        Apttus_Config2__InformationType__c = 'Attached File',
                        Name = 'Product Image',
                        Apttus_Config2__ProductId__c = prod.Id,
                        Apttus_Config2__Sequence__c = 1,
                        Apttus_Config2__Type__c = 'Manual'
                    ));
                }
                System.debug('prodInfoToInsert >> ' + prodInfoToInsert);
                if(!prodInfoToInsert.isEmpty()){
                    insert prodInfoToInsert;
                    // Create map of product id and product information
                    Map<Id,Apttus_Config2__ProductInformation__c> mapOfProdIdVsProdInfo = new Map<Id,Apttus_Config2__ProductInformation__c>();
                    Map<Id,Apttus_Config2__ProductInformation__c> mapOfIdVsProdInfo = new Map<Id,Apttus_Config2__ProductInformation__c>();
                    for(Apttus_Config2__ProductInformation__c info : prodInfoToInsert){
                        mapOfProdIdVsProdInfo.put(info.Apttus_Config2__ProductId__c, info);
                        mapOfIdVsProdInfo.put(info.Id, info);
                    }
                    System.debug('mapOfProdIdVsProdInfo >> ' + mapOfProdIdVsProdInfo);
                    System.debug('mapOfIdVsProdInfo >> ' + mapOfIdVsProdInfo);
                    // Create Attachment
                    List<Attachment> attachmentToInsert = new List<Attachment>();
                    for(Attachment att : attachments){
                        Attachment tempAttachment = new Attachment();
                        tempAttachment = att.clone(false,true,false,false);
                        tempAttachment.parentId = mapOfProdIdVsProdInfo.get(att.parentId).Id;
                        attachmentToInsert.add(tempAttachment);
                    }
                    System.debug('attachmentToInsert >> '+ attachmentToInsert);
                    // Insert Attachment
                    if(!attachmentToInsert.isEmpty()){
                        insert attachmentToInsert;
                    }
                    // Update Product and Product Information field now
                    List<Product2> productToUpdate = new List<Product2>();
                    List<Apttus_Config2__ProductInformation__c> prodInfoToUpdate = new List<Apttus_Config2__ProductInformation__c>();
                    for(Attachment att : attachmentToInsert){
                        if(mapOfIdVsProdInfo.get(att.ParentId) != null){
                            // Add Prod Info to prodInfoToUpdate
                            prodInfoToUpdate.add(new Apttus_Config2__ProductInformation__c(Id = att.ParentId, Apttus_Config2__FileId__c = att.Id));
                            // Check for Prodcut2 in maps
                            if(mapOfIdVsProdInfo.get(att.ParentId).Apttus_Config2__ProductId__c != null){
                                productToUpdate.add(new Product2(Id = mapOfIdVsProdInfo.get(att.ParentId).Apttus_Config2__ProductId__c, Apttus_Config2__IconId__c = att.Id));
                            }
                        }
                    }
                    System.debug('prodInfoToUpdate >>'+ prodInfoToUpdate);
                    if(!prodInfoToUpdate.isEmpty()){
                        update prodInfoToUpdate;
                    }
                    System.debug('productToUpdate >>'+ productToUpdate);
                    if(!productToUpdate.isEmpty()){
                        update productToUpdate;
                    }
                }
            }
        }
    }
}