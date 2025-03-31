crmc.require(["KendoEntry", "KendoPopup", "sfdc"], function(kendoEntry, kendoPopup, sfdc) {
crmc.addCustomAction({
  itemID: "Apttus__Agreement_Clause__c",
  isAvailable: function(context) {
    var isAccessible = context.objectDescribe.name == this.itemID; 
	  var singleSelected = context.selectedRows;
	  var isFieldAvailable = true;
	  console.log('isAccessible:'+isAccessible+'singleSelected:'+singleSelected);
	  return isAccessible && singleSelected && isFieldAvailable; 
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
    return "Compare Clause Text";
  },
  createSubmenuItems: function(context) {
    // If this function returns additional action item objects, they will appear as submenu items
    return [];
  },
  click: function(context) {
	console.log('context',context);
	if(context.selectedRows && context.selectedRows.length > 0){
	  let scriptEle = document.createElement("script");
    scriptEle.setAttribute("src", 'https://cdnjs.cloudflare.com/ajax/libs/diff_match_patch/20121119/diff_match_patch.js');
    scriptEle.setAttribute("type", "text/javascript");
    //scriptEle.setAttribute("async", false);
    document.body.appendChild(scriptEle);
  
    // success event 
    scriptEle.addEventListener("load", () => {
      console.log("File loaded")
      
      var agreementClauseName = context.selectedRows[0].Apttus__Clause__c;
  		var agreementClauseId = context.selectedRows[0].Id;
  		var agreementClauseText = context.selectedRows[0].Apttus__Text__c;
  		var TemplateName = 'Not Available';
		
		if(context.selectedRows[0].Apttus__Template__c != null){
			TemplateName = context.selectedRows[0].Apttus__Template__r.Name;
		}
		
  		var TemplateClauseText = context.selectedRows[0].APTSMD_Original_Text__c;
  		var agrClauseQuery = [];
  		var dmp = new diff_match_patch();
		console.log("agreementClauseText:" + agreementClauseText);
		console.log("TemplateClauseText:" + TemplateClauseText);
		console.log("File loaded")
  		if(!TemplateClauseText || !agreementClauseText){
  		  alert("Please make sure selected record has valid values in the Clause Texts fields");
  		  return;
  		}
  		var d = dmp.diff_main(TemplateClauseText,agreementClauseText);
  		dmp.diff_cleanupSemantic(d);
  		var ds = dmp.diff_prettyHtml(d);
  		ds = ds.replaceAll('background:', 'color:').replaceAll('#ffe6e6','red').replaceAll('#e6ffe6','green');
  		var dialogUI = '<html><body><table><tr><th class="tdthclass" style="background-color: #e6ffe6;">Agreement Clause</th><th class="tdthclass" style="background-color: #ffe6e6;">Clause Library</th></tr><tr class="tdthclass"><td class="tdthclass" style="bgcolor:">'+agreementClauseName+'</td><td class="tdthclass">'+TemplateName+'</td></tr></table><br/><div style="border: 1px solid #dddddd !important; padding:10px;">'+ds+'</div></body></html>';
  			
  		var buttons = [{
  			label:"Save Difference",
  			click: function(){
  				console.log("Called");
  				agrClauseQuery = sforce.connection.query("Select id,Apttus__DiffText2__c from Apttus__Agreement_Clause__c where Id ='"+agreementClauseId+"' limit 1");
  				var records = agrClauseQuery.getArray("records");
  
  				
  				console.log("agrClauseQuery:"+records[0].Apttus__DiffText2_c);
  				if(records.length>0){
  					console.log("inner side:"+records[0]);
  					records[0].Apttus__DiffText2__c =  ds;
  					result = sforce.connection.update(records);
  					console.log("result:"+result);
  					if (result[0].getBoolean("success")) {
  						console.log("Agreement clause is updated");
  						window.location.reload();
  					} else {
  						console.log("failed to update agreement clause." + result[0]);
  					}
  				}
  			}
  		}];
  		kendoPopup.popupWithButtons("Compare Clause Text", dialogUI, buttons);
  	  
      
    });
     // error event
    scriptEle.addEventListener("error", (ev) => {
      console.log("Error on loading file", ev);
    });
    
		}else{
  		  alert("Please select clause from library with original text.");
  	  }
	}
});
});