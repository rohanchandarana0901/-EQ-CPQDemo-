({
    createACW: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=Request Supplier'}).fire();

    }
})