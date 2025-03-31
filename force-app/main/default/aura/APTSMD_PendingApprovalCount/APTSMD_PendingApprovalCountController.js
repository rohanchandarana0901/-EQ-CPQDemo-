({
    doInit : function(component, event, helper) {
        helper.getActionRequiredCount(component);
	},
	gotoList: function(component, event, helper) {
	    var url = '/lightning/n/cnga__ApprovalCenter';
        $A.get("e.force:navigateToURL").setParams({"url": url}).fire();
    } 
})