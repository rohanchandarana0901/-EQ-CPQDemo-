({
	doInit : function(component, event, helper) {
        var qId = component.get("v.recordId");
        helper.getOrder(component, qId);
	},
    update : function (component, event, helper) {
        console.log('AAAAA');
        var qId = component.get("v.recordId");
        helper.getOrder(component, qId);
    },
    configureProducts : function (component, event, helper) {
        console.log('###Configure Products');
        //console.log('###Order'+v);
        var qId = component.get("v.recordId");
        var orderRecord = component.get("v.order");
        console.log('orderRecord >> ',orderRecord);
        var flow = orderRecord.APTSMD_Flow__c; //component.get("v.flow");
        console.log('flow >>',flow);
        if(flow == null || flow == ''){
        	flow='Default';   
        }
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__OrderConfiguration?id=' + qId + '&flow='+flow+'&asyncFinalize=true&useAdvancedCurrency=true'}).fire();
    },
    activateOrder : function (component, event, helper) {
        console.log('###Activate Order');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSCU_ActivateOrder?id=' + qId}).fire();
    },
    amendOrder : function (component, event, helper) {
        console.log('###Amend Order');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__OrderAmend?id=' + qId}).fire();
    },
    cancelOrder : function (component, event, helper) {
        console.log('###Cancel Order');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__OrderCancel?id=' + qId}).fire();
    },
    acceptOrder : function (component, event, helper) {
        console.log('###Accept Order');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__OrderAccept?id=' + qId}).fire();
    },
    undoAmendOrder : function (component, event, helper) {
        console.log('###Undo Amend Order');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__UndoOrderAmend?id=' + qId}).fire();
    },
    undoCancelOrder : function (component, event, helper) {
        console.log('###Undo Cancel Order');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__UndoOrderCancel?id=' + qId}).fire();
    }
})