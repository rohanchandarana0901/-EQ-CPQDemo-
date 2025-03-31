({
	generateInvoice : function (component, event, helper) {
        var accountId = component.get("v.recordId");
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Billing__GenerateInvoice?id=' + accountId}).fire();
      	$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_GenerateInvoice?id=' + accountId}).fire();
    },
    invoiceOverview : function (component, event, helper) {
        var accountId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Billing__PreviewInvoices2?id=' + accountId}).fire();
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_PreviewInvoices?id=' + accountId}).fire();
    },
    invoiceRuns : function (component, event, helper) {
        var accountId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Billing__InvoiceRunCreate?retURL=%2F'+accountId}).fire();
    },
    agreementHierarchy : function(component, event, helper) {
        var accountId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus__AgreementHierarchyByAccount?id=' + accountId}).fire();
    },
    openUsageManagementApp : function (component, event, helper) {
        var accountId = component.get("v.recordId");
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Billing__GenerateInvoice?id=' + accountId}).fire();
      	$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_OpenUsageManagementXAEApp?id=' + accountId}).fire();
    },
    assetManager : function (component, event, helper) {
        var accountId = component.get("v.recordId");
      	$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_AssetManagerPage?id=' + accountId}).fire();
    }
    
})