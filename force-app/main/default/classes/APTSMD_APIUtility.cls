/* 
*  Class        : APTSMD_APIUtility
*  Purpose      : Reusable Apttus API Methods
*  Created By   : Chetan Patel
*/

public class APTSMD_APIUtility {
    
    // CPQ API Methods
    
    /*
     *  Parameters: ProposalId
     *  Will return new Product Configuration ID with status 'New'
     */
    public static String createCart(String quoteId){
        
          Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
          request.QuoteId = quoteId;
          Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request); 
          String  cartId = response.CartId; 
          return cartId;
    }
    
    /*
     *  Parameters: Configuration Id
     *  Result: Only line items in pending status are updated
     *  Return: isPricePending : True (If any line item is in pending status)
     */
    public static Boolean repriceCart(String cartId){
        
        Apttus_CPQApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CPQApi.CPQ.UpdatePriceRequestDO();
        objUpdatePriceRequestDO.CartId = cartId;
        Apttus_CpqApi.CPQ.UpdatePriceResponseDO objUpdatePrice = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
        
        return objUpdatePrice.IsPricePending;
    }
    
    /*
     *  Parameters: Configuration Id
     *  Result: The configuration is finalized, synchronizing the cart line items with the quote/proposal
     *  Return: isSuccess : True (if finalize cart was successful)
     */
    public static Boolean finalizeCart(String configId){
        
        Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();                 
        request.CartId = configId; 
        Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request); 
        return response.IsSuccess;
    }
    
    
    /*
     *  Parameters: Configuration Id
     *  Result: This processes and applies all the constraint rules
     */
    public static void applyConstraintRules(String cartId){
        
        Apttus_CPQApi.CPQWebService.applyConstraintRules(cartId, false);
    }
    
    /*
     *  Parameter 1: Configuration Id
     *  Parameter 2: List of Products (Wrapper Class created in this class) to be added
     *  Result: Add procucts to the cart
     *  Return: list of line item - line numbers
     */
    public static List<Decimal> addProducts(String cartId, List<Product> lstProducts){
        
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requests.CartId = cartId;
        requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
        
        for(Product p : lstProducts) {
            Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
            prodDO.ProductId = p.productId;
            prodDO.Quantity  = p.quantity;
            requests.SelectedProducts.add(prodDO);
                
        }
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        return response.LineNumbers;

    }
    
    /*
     *  Parameter 1: Configuration Id
     *  Parameter 2: List of Line Items' line numbers
     *  Result: Removes one or more products (with default options) or bundles from the cart along with quantity, term, start date and end date
     *  Return: isSuccess : True - if products removed, successfully
     */
    public static Boolean removeProducts(String cartId, List<Decimal> lineNumberList){
        
        Apttus_CPQApi.CPQ.RemoveMultiBundlesRequestDO request = new Apttus_CPQApi.CPQ.RemoveMultiBundlesRequestDO();
        request.CartId = cartId;
        request.LineNumbers = lineNumberList;
        Apttus_CPQApi.CPQ.RemoveMultiBundlesResponseDO response = Apttus_CPQApi.CPQWebService.removeMultiBundles(request);

        return response.IsSuccess;
    }
    
    /*
     *  Parameter 1: Configuration Id
     *  Result: Sync the shopping cart with the product configuration on the quote record
     *  Return: isSuccess : True - if successful
     */
    public static Boolean synchronizeCart(String cartId){
        
        Apttus_CPQApi.CPQ.SynchronizeCartRequestDO request = new Apttus_CPQApi.CPQ.SynchronizeCartRequestDO();
        request.CartId = cartId;
        Apttus_CPQApi.CPQ.SynchronizeCartResponseDO response = Apttus_CPQApi.CPQWebService.synchronizeCart(request);
        
        return response.IsSuccess;
    }
    
    
    /*
     *  Parameters: Configuration Id
     *  Result: Deletes the selected cart in Draft status
     *  Return: isSuccess - True if successfully deleted cart
     */
    public static Boolean abandonCart(String cartId){
        
        Apttus_CPQApi.CPQ.AbandonCartRequestDO request = new Apttus_CPQApi.CPQ.AbandonCartRequestDO();
        request.CartId = cartId;
        Apttus_CPQApi.CPQ.AbandonCartResponseDO response = Apttus_CPQApi.CPQWebService.abandonCart(request);
        
        return response.IsSuccess;
    }
    
    /*
     *  Parameter 1: Configuration Id
     *  Parameter 2: Primary Line numbers of Config lines
     *  Result: Clone the Primary bundle line items along with option line items and child line items(if applicable) on the cart
     */
    public static void cloneBundleLineItems(String cartId, List<Integer> primaryLineNumbers){

        Apttus_CPQApi.CPQ.CloneLineItemsRequestDO request = new Apttus_CPQApi.CPQ.CloneLineItemsRequestDO();
        request.CartId = cartId;
        request.PrimaryLineNumbers = primaryLineNumbers;
        Apttus_CPQApi.CPQ.CloneLineItemsResponseDO result = Apttus_CPQApi.CPQWebService.cloneBundleLineItems(request);
        
    }
    
    /*
     *  Parameter:  Proposal Id 
     *  Result: Proposal is accepted
     *  Return: True - if proposal is accepted, successfully
     */ 
    public static Boolean acceptQuote(String quoteId){
        
        return Apttus_QPConfig.QPConfigWebService.acceptQuote(quoteId); 
    }
    
    
    //Order Management API Methods
    
    /*
     *  Parameter 1:    Account Id
     *  Parameter 2:    Price List Id
     *  Result: Creates and order for a specific Account and Price List
     *  Return: Generated Order's Id
     */
    public static String createOrder(String accountId,String priceListId){
        
        Apttus_Config2.CPQStruct.CreateOrderRequestDO request = new Apttus_Config2.CPQStruct.CreateOrderRequestDO();
        request.AccountId = accountId;
        request.PriceListId = priceListId;
        request.PricingDate = Datetime.now();
        Apttus_Config2.CPQStruct.CreateOrderResponseDO result = Apttus_Config2.OrderWebService.createOrder(request);
        
        return result.OrderSO.Id;
    }
    
    /*
     *  Parameter:  Order Id
     *  Result: Creates a cart for the order referenced by OrderId
     *  Return: Generated Proposal's Id
     */
    public static String createCartOnOrder(String orderId) {
        
        List<Apttus_Config2.Property> configProps = new List<Apttus_Config2.Property>();
        Apttus_Config2.Property prop = new Apttus_Config2.Property();
        prop.Name = 'useAdvancedApproval';
        prop.Value = 'false';
        configProps.add(prop);
        prop = new Apttus_Config2.Property();
        prop.Name = 'useDealOptimizer';
        prop.Value = 'false';
        configProps.add(prop);
        
        Apttus_Config2.CPQStruct.CreateCartRequestDO request = new Apttus_Config2.CPQStruct.CreateCartRequestDO();
        request.OrderId = orderId;
        request.Properties.addAll(configProps);
        Apttus_Config2.CPQStruct.CreateCartResponseDO response = Apttus_Config2.OrderWebService.createCart(request);
        
        return response.CartId;
    }
    
    /*
     *  Parameters: Configuration Id
     *  Result: Sync the shopping cart line items with the order line items
     *  Return: isSuccess - True, if order lines created, successfully
     */
    public static Boolean synchronizeCartOnOrder(String cartId){
        Apttus_Config2.CPQStruct.SynchronizeCartRequestDO request = new Apttus_Config2.CPQStruct.SynchronizeCartRequestDO();
        request.CartId = cartId;
        Apttus_Config2.CPQStruct.SynchronizeCartResponseDO response = Apttus_Config2.OrderWebService.synchronizeCart(request);
        
        return response.IsSuccess;
    }
    
    /*
     *  Parameters: Order Id
     *  Result: After finalizing and synchronizing cart, this will created Asset line items for an order
     */
    public static void createAsset(String orderId){
        
        Apttus_Config2.CPQStruct.CreateAssetRequestDO request = new Apttus_Config2.CPQStruct.CreateAssetRequestDO();
        request.OrderId = orderId;
        Apttus_Config2.CPQStruct.CreateAssetResponseDO response = Apttus_Config2.OrderWebService.createAsset(request);
    }
    
    public static void acceptOrder(String orderId) {
        
        // Apttus_Config2.CPQStruct.AcceptOrderRequestDO request = new Apttus_Config2.CPQStruct.AcceptOrderRequestDO();
        // request.OrderId = orderId;
        // Apttus_Config2.CPQStruct.AcceptOrderResponseDO response = Apttus_Config2.OrderWebService.acceptOrder(request);

        // return response.IsSuccess;
    }
    
    /*
     *  Asset management API methods
     */
    
    
    /*
     *  Parameter 1: Configuration Id
     *  Parameter 2: List of Asset Ids
     *  Result: Change Assets
     */
    public static void changeAssets(String cartId, List<Id> listAssetIds){
        Apttus_Config2.CPQStruct.ChangeAssetsRequestDO request = new Apttus_Config2.CPQStruct.ChangeAssetsRequestDO();
        request.AssetIds = listAssetIds;
        request.CartId = cartId;
        Apttus_Config2.CPQStruct.ChangeAssetsResponseDO response = Apttus_Config2.AssetService.changeAssets(request);
    }
    
    
    /*
     *  Parameter 1: Renew Date
     *  Parameter 2: Renew Term
     *  Parameter 3: List of Asset Ids
     *  Parameter 4: Configuration Id
     *  Result: Renew Assets
     */
    public static void renewAssets(Date renewEndDate, Double renewTerm, List<Id> listOfAssetIds, String cartId){
        Apttus_Config2.CPQStruct.RenewAssetsRequestDO request = new Apttus_Config2.CPQStruct.RenewAssetsRequestDO();
        request.RenewEndDate = renewEndDate;
        request.RenewTerm = renewTerm;
        request.AssetIds = listOfAssetIds;
        request.CartId = cartId;
        
        Apttus_Config2.CPQStruct.RenewAssetsResponseDO response = Apttus_Config2.AssetService.renewAssets(request);
    }
    
    
    /*
     *  Parameter 1:    List of ProductIDs
     *  Parameter 2:    Start Date for new Asset
     *  Parameter 3:    List of Asset Ids
     *  Parameter 4:    Configuration Id
     *  Result: Swappnig Assets
     */
    public static void swapAssets(List<Id> lstOfProductIds, Date newStartDate, List<Id> listOfAssetIds, String cartId){
        Apttus_Config2.CPQStruct.SwapAssetsRequestDO request = new Apttus_Config2.CPQStruct.SwapAssetsRequestDO();
        request.ProductIds = lstOfProductIds;
        request.NewStartDate = newStartDate;
        request.AssetIds = listOfAssetIds;
        request.CartId = cartId;
        
        Apttus_Config2.CPQStruct.SwapAssetsResponseDO response = Apttus_Config2.AssetService.swapAssets(request);
 
    }
    
    /*
     *  Parameter 1:    Cancelled Date 
     *  Parameter 2:    List of Asset Ids
     *  Parameter 3:    Configuration Id
     *  Result: Cancelling Assets
     */
    public static void terminateAssets(Date cancelledDate, List<Id> listAssetId, String cartId){
        Apttus_Config2.CPQStruct.CancelAssetsRequestDO request = new Apttus_Config2.CPQStruct.CancelAssetsRequestDO();
        request.CancelDate = cancelledDate;
        request.AssetIds = listAssetId;
        request.CartId = cartId;
        
        Apttus_Config2.CPQStruct.CancelAssetsResponseDO response = Apttus_Config2.AssetService.cancelAssets(request);
    }
    
    /*
     *  Agreement APIs
     */
    
    /*
     *  Parameter 1: Agreement Id
     *  Parameter 2: Document ids to be activated
     *  Parameter 3: Document Ids to be removed
     *  Result: Agreement is activated. i.e. Status - 'Activated'
     *  Return: True, if successfully activated
     */
    public static Boolean activateAgreement(Id agreementId, String[] activateDocIds, String[] removeDocIds){
        Boolean response = Apttus.AgreementWebService.activateAgreement(agreementId, activateDocIds, removeDocIds);
        return response;
    }
    
    /*
     *  Parameter 1: Agreement Id
     *  Parameter 2: Document Id
     *  Result: Publishes the agreement document for the activated agreement to Chatter > Files for the salesforce object the agreement is associated with
     *  Return: True, if successfully published
     */
    public static Boolean publishAgreementDocToChatterRepository(Id agreementId, Id publishDocId){
        Boolean response = Apttus.AgreementWebService.publishToChatterRepository(agreementId, publishDocId);
        return response;
    }
    
    /*
     *  Parameter 1: Email Template Id
     *  Parameter 2: Proposal Id
     *  Parameter 3: Access Level
     *  Parameter 4: Document Format PDF/Doc etc
     *  Parameter 5: Session Id
     *  Result: Generates a Word agreement document by using the template specified by the templateId and the agreement indicated by the agreementId.
                The document is added to the Files and Attachments section for the Agreement object
     *  Return: DocumentId, attachment created on Agreement
     */
    public static String generateDocOnAgreement(Id templateId, Id proposalId, String accessLevel, String docFormat, String apiSessionId){
        String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        String generatedDocId = Apttus_Proposal.MergeWebService.generateDoc(templateId, proposalId, accessLevel, docFormat, apiSessionId, apiServerURL);
        return generatedDocId;
    }
    
    //Converting a Word Document into a PDF
    /*
     *  Parameter 1: Document Id
     *  Parameter 2: File Name
     *  Parameter 3: Add Water Mark
     *  Parameter 4: Remove Water Mark
     *  Parameter 5: Header Text
     *  Parameter 6: Footer Text
     *  Parameter 7: Session Id
     *  Result: This converts a Word document into a PDF Document. It can be any Word document and does not have to be created using generateDoc or generateSupportingDoc.
     *  Return: DocumentId that was converted to PDF
     */
    public static Id convertWordDocToPDF(Id docId, String fileName, Boolean addWaterMark, Boolean removeWatermark, String headerText, String footerText, String apiSessionId){
        String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        Id convertedDocId = Apttus.MergeWebService.convertWordDocToPDF(docId, fileName, addWatermark, removeWatermark, headerText, footerText, apiSessionId, apiServerURL);
        return convertedDocId;
    }
    
    /*
     *  Parameter 1: TemplateId
     *  Parameter 2: Proposal Id
     *  Parameter 3: Access Level
     *  Parameter 4: Document Format
     *  Parameter 5: Session Id
     *  Result: 
     *  Return: Document Id created on proposal
     */
    public static String generateDocOnProposal(Id templateId, Id proposalId, String accessLevel, String docFormat, String apiSessionId){
        String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        String generatedDocId = Apttus_Proposal.MergeWebService.generateDoc(templateId, proposalId, accessLevel, docFormat, apiSessionId, apiServerURL);
        return generatedDocId;
    }
    
    // code ends
    
    /*
    * Parameters:
    * parentId = Agreement Id
    * docIds = List of Agreement Ids to be enabled
    * apiSessionId = Current User’s session id
    *
    */
    public static void enableAuthoringCallout(Id parentId, List<Id> docIds, String apiSessionId)
    {
        String pLevel = 'Insert comments and tracked changes only';
        String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + '/services/Soap/u/14.0/'  + UserInfo.getOrganizationId();
        if(!Test.isRunningTest()){
            Boolean enableAuthoringStatus = Apttus.MergeWebService.enableAuthoring(parentId, pLevel, docIds, apiSessionId, apiServerURL);
        }
    }
    
    public class Product{
        
        public boolean isBundle {get; set;}
        public Map<String,Decimal> mapOptionWithquantity {get; set;}
        public String productId {get; set;}
        public Decimal quantity {get; set;}
        
        /*
         *  added constructor, so that user can create and initiate a list of this class and pass it to addProducts method
         */
        public product(Boolean isBundleCheck, Map<String,Decimal> mapOptions, String prodId, Decimal qty){
            this.isBundle = isBundleCheck;
            this.mapOptionWithquantity = mapOptions;
            this.productId = prodId;
            this.quantity = qty;
        }
        
    }
     
}