({
    doInit : function(component, event, helper) {
       helper.getRecordTypes(component);        
       helper.getAccounts(component);        
	},
    searchContent : function(component, event, helper) {
        let searchText = component.find("searchText").get("v.value"); 
        let account = component.find("selectAccount").get("v.value"); 
        let recordType = component.find("selectRecordType").get("v.value");         
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_ContractSearch?search=' + searchText + '&recordtypeName=' + recordType + '&accountName='+ account,"target": "_blank"}).fire();      
    },
    searchContentEnter : function(component, event, helper) {
        if (event.getParams().keyCode == 13) {
        	let searchText = component.find("searchText").get("v.value"); 
        	let account = component.find("selectAccount").get("v.value"); 
        	let recordType = component.find("selectRecordType").get("v.value");         
        	$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_ContractSearch?search=' + searchText + '&recordtypeName=' + recordType + '&accountName='+ account,"target": "_blank"}).fire();
        }
   }
})