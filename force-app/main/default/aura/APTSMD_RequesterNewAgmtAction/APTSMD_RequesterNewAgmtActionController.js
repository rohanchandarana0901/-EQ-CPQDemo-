({
    createACW: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=Agreement Creation Wizard'}).fire();
    }
})