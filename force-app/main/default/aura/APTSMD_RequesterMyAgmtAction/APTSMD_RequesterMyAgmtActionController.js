({
    gotoMyAgreements: function(component, event, helper) {       
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/n/My_Agreements'}).fire();
    }
})