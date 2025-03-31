({
    doInit : function(component, event, helper) {
        helper.getMyReports(component);        
             
        
	},
	gotoList: function(component, event, helper) { 
	    var url = '/lightning/o/Report/home?queryScope=created';
        $A.get("e.force:navigateToURL").setParams({"url": url}).fire();
    } 
})