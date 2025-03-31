({
    doInit : function(component, event, helper) {
        helper.getMyContracts(component);        
        helper.getMyContractsView(component);        
        
	},
	gotoList: function(component, event, helper) {
	    var ContractsView = component.get("v.ContractsView");
	    var url = '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+ContractsView;
        $A.get("e.force:navigateToURL").setParams({"url": url}).fire();
    } 
})