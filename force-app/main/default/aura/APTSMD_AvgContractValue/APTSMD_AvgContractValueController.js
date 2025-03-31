({
    doInit : function(component, event, helper) {
        helper.getAvgContractValue(component);        
        helper.getAvgACVView(component);        
	},
	gotoList: function(component, event, helper) {
	    var AvgACVView = component.get("v.AvgACVView");
	    var url = '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+AvgACVView;
        $A.get("e.force:navigateToURL").setParams({"url": url}).fire();
    } 
})