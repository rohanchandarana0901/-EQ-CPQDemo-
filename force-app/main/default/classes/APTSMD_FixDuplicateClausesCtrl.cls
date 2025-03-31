public class APTSMD_FixDuplicateClausesCtrl {
    
    // Initialize variables
    Private List<Apttus__APTS_Template__c> allDuplicateTemplates;
    
    // Constructor initialization
    public APTSMD_FixDuplicateClausesCtrl(){
        // Declare List 
        allDuplicateTemplates = new List<Apttus__APTS_Template__c>();
        // Fetch all templates which are duplicate
        allDuplicateTemplates = [SELECT Id, Name, Apttus__Type__c FROM Apttus__APTS_Template__c WHERE Apttus__Type__c = 'Clause' 
                                    AND Apttus__Category__c = 'Category' AND Apttus__Subcategory__c = 'SubCategory' AND Apttus__IsActive__c = True];
        
        
    }
    
    // deleteAllDuplicateClauses() - Delete all clauses which are duplicated according to conditions
    public PageReference deleteAllDuplicateClauses(){
        // Check for list if empty or not
        if(allDuplicateTemplates.size() > 0){
            // Delete allDuplicateTemplates list
            try{
                // For Delete (Right now commented)
                //Delete allDuplicateTemplates;
                
                // For Deactivate
                for(Apttus__APTS_Template__c template : allDuplicateTemplates){
                    template.Apttus__IsActive__c = false;
                }
                // Update list
                Update allDuplicateTemplates;
            }catch(Exception ex){
                System.debug('Exception -> ' + ex);
            }
        }
        
        // Return to previous page
        //System.debug('ApexPages.currentPage().getHeaders().get' + ApexPages.currentPage().getHeaders().get('Referer'));
        //return new PageReference(ApexPages.currentPage().getHeaders().get('Referer'));
        PageReference pr = new PageReference('/');
        pr.setRedirect(true);
        return pr;
    }
    
}