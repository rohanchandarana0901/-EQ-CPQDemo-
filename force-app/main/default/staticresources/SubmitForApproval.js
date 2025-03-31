crmc.require(["KendoEntry", "KendoPopup", "sfdc"],function (kendoEntry, kendoPopup, sfdc) {
crmc.addCustomAction({
  itemID: "actionName",
  isAvailable: function(context) {
    // This function is called before the action item is displayed and returns a boolean if the item should be displayed
    // By default determine availability based on Feature Security for this action
		var isValidRequest = true;
        var selectedOpp = context.selectedRows;
		if(selectedOpp.length>0){
			isValidRequest=true;
		}
		else{
			isValidRequest=false;
		}
        
        return (
          this.featureSecurity.getSetting(
            context.objectDescribe.name,
            this.itemID
          ) !== false && isValidRequest
        );
	
    return this.featureSecurity.getSetting(context.objectDescribe.name, this.itemID) !== false;
  },
  isHeaderAvailable: function(context) {
    // This function determines if this item can be displayed from the column header menu
    return false;
  },
  isToolbarAvailable: function(context) {
    // This function determines if this item can be displayed in the Toolbar as a button
    return false;
  },
  getLabel: function(context) {
    // This function returns the display label of the action item and is called before the item is shown
    return "Submit For Approval";
  },
  createSubmenuItems: function(context) {
    // If this function returns additional action item objects, they will appear as submenu items
    return [];
  },
  click: function(context) {
    // This function is what is executed when the action item is clicked
    // Context object has this format:
    /* {
        objectDescribe: metadata for current object
        selectedRows: rows selected in AG
        loadedRows: all rows loaded in AG
        isHeader: true if header column initiated action
        selectedColumn: if header Action, info about the column which was clicked
        kendoGrid: kendoGrid object
    } */
    
	var selectedOpps = [];
	var selectedOpps = context.selectedRows;
	var selectedOppIds='';
	//var ids='';
	if(selectedOpps.length>0){
		for(var i = 0; i < selectedOpps.length; i++){
			//selectedOppIds.push(selectedOpps[i].id);
			if(i!=selectedOpps.length-1){
				selectedOppIds = selectedOppIds + "'" + selectedOpps[i].id + "',";
			}
			else{
				selectedOppIds = selectedOppIds + "'" + selectedOpps[i].id + "'";
			}
		}
		if(selectedOppIds.length > 1) {
		  selectedOppIds.substr(0, selectedOppIds.length - 1);
		}
		console.log("Select Id,APTSMD_Is_Approval_Required__c from Opportunity WHERE Id IN ("+selectedOppIds+")");
		result = sforce.connection.query("Select Id, APTSMD_Is_Approval_Required__c from Opportunity WHERE Id IN ("+selectedOppIds+")");
		records = result.getArray("records");
		var oppList=[];
		for (var i=0; i< records.length; i++) {
			records[i].APTSMD_Is_Approval_Required__c=true;
			oppList.push(records[i]);
		}
		
		var results = sforce.connection.update(oppList);
		var failed = ["<ul>"];
		kendoPopup.popup(
            "Message",
            "Opportunit(ies) successfully submitted for Approval!"
          );
		context.actionGrid.refresh();
	}
	else{
			kendoPopup.popup(
			     "Message",
            "No rows selected."
      );
	}
	}
});
});