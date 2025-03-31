trigger APTSMD_PreventAiiClauseInsert on Apttus__APTS_Template__c (after insert) {
    List<Apttus__APTS_Template__c> templatesToDelete = new List<Apttus__APTS_Template__c>();
    for (Apttus__APTS_Template__c template : trigger.new) {
        if (template.Apttus__Type__c == 'Clause' 
            && template.Apttus__Category__c == 'Category' 
            && template.Apttus__Subcategory__c == 'SubCategory') {
            
            // deactivate
            //template.Apttus__IsActive__c = false;
            
            // delete
            templatesToDelete.add(template);
        }
    }
    
    if (templatesToDelete.size() > 0) {
        delete templatesToDelete;
    }
}