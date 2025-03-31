crmc.require(
  ["KendoEntry", "KendoPopup", "sfdc"],
  function (kendoEntry, kendoPopup, sfdc) {
    crmc.addCustomAction({
      itemID: "massAmend",

      isAvailable: function (context) {
        // This function is called before the action item is displayed and returns a boolean if the item should be displayed

        // By default determine availability based on Feature Security for this action
        var isValidAmendRequest = true;
        var selectedAgreements = context.selectedRows;
        for (var i = 0; i < selectedAgreements.length; i++) {
          if (
            selectedAgreements[i].Apttus__Status_Category__c != "In Effect" &&
            selectedAgreements[i].Apttus__Status__c != "Activated"
          ) {
            isValidAmendRequest = false;
          }
        }
        return (
          this.featureSecurity.getSetting(
            context.objectDescribe.name,
            this.itemID
          ) !== false && isValidAmendRequest
        );
      },

      isHeaderAvailable: function (context) {
        // This function determines if this item can be displayed from the column header menu

        return false;
      },

      isToolbarAvailable: function (context) {
        // This function determines if this item can be displayed in the Toolbar as a button

        return false;
      },

      getLabel: function (context) {
        // This function returns the display label of the action item and is called before the item is shown

        return "Amend Agreements";
      },

      createSubmenuItems: function (context) {
        // If this function returns additional action item objects, they will appear as submenu items

        return [];
      },

      click: function (context) {
        Date.prototype.addDays = function (days) {
          var date = new Date(this.valueOf());
          date.setDate(date.getDate() + days);
          return date;
        };
        function formatDate(date) {
          var d = new Date(date),
            month = "" + (d.getMonth() + 1),
            day = "" + d.getDate(),
            year = d.getFullYear();

          if (month.length < 2) month = "0" + month;
          if (day.length < 2) day = "0" + day;

          return [year, month, day].join("-");
        }
        var displayResult = [];
        var startdate = new Date();
        var enddate = startdate.addDays(365);
        var effectivedate = startdate.addDays(5);
        var startdatestr = formatDate(startdate);
        var enddatestr = formatDate(enddate);
        var effectivedatestr = formatDate(effectivedate);

        var buttons = [
          {
            label: "Cancel",
            click: function () {},
          },
          {
            label: "Amend",
            click: function (event, element) {
              document.getElementsByClassName(
                "slds-button_brand"
              )[0].disabled = true;
              document.getElementsByClassName(
                "slds-button_brand"
              )[0].innerText = "Amending...";
              var newStartDate = document.getElementById("newStartDate");
              var newEndDate = document.getElementById("newEndDate");
              var newEffectiveDate = document.getElementById(
                "newEffectiveDate"
              );
              var newTerms = document.getElementById("newTerms");

              context.kendoGrid._progress && context.kendoGrid._progress(true);

              var failed = ["<ul>"];

              function ShowErrors() {
                kendoPopup.popupWithButtons(
                  "Error Occured While Amending Agreement(s)",
                  failed.join(""),
                  [{ label: "Ok" }],
                  { width: 600 }
                );
              }

              function Success() {
                var table = "<table>";
                var rows = "";
                for (var i = 0; i < displayResult.length; i++) {
                  rows +=
                    "<tr><td><a target='_blank' href='/" +
                    displayResult[i].Id +
                    "'>" +
                    displayResult[i].Name +
                    "</a></td></tr>";
                }
                table = table + rows + "</table>";
                kendoPopup.popupWithButtons(
                  "Agreement(s) Amended Successfully!",
                  table,
                  [{ label: "Ok" }],
                  { width: 600 }
                );
              }

              var selectedAgreements = [];

              var selectedAgreements = context.selectedRows;

              for (var i = 0; i < selectedAgreements.length; i++) {
                try {
                  // calling amendment web service

                  var amendAgreementWebServiceCallOut = sforce.apex.execute(
                    "Apttus.ComplyWebService",
                    "amendAgreement",
                    { originalId: selectedAgreements[i].id }
                  );

                  // Output is in XML Form, we need to convert it in to sObject
                  var amendAgreementClause = new sforce.SObject(
                    "Apttus__Agreement_Clause__c"
                  );

                  var amendAgreementInsertList = new sforce.SObject(
                    "Apttus__APTS_Agreement__c"
                  );

                  amendAgreementInsertList.Name =
                    amendAgreementWebServiceCallOut[0].Name;

                  amendAgreementInsertList.Apttus__Agreement_Number__c =
                    amendAgreementWebServiceCallOut[0].Apttus__Agreement_Number__c;

                  amendAgreementInsertList.Apttus__Version_Number__c =
                    amendAgreementWebServiceCallOut[0].Apttus__Version_Number__c;

                  amendAgreementInsertList.Apttus__Account__c =
                    amendAgreementWebServiceCallOut[0].Apttus__Account__c;
                  if (newStartDate.value) {
                    amendAgreementInsertList.Apttus__Contract_Start_Date__c =
                      newStartDate.value;
                  } else {
                    amendAgreementInsertList.Apttus__Contract_Start_Date__c =
                      amendAgreementWebServiceCallOut[0].Apttus__Contract_Start_Date__c;
                  }

                  if (newEndDate.value) {
                    amendAgreementInsertList.Apttus__Contract_End_Date__c =
                      newEndDate.value;
                  } else {
                    amendAgreementInsertList.Apttus__Contract_End_Date__c =
                      amendAgreementWebServiceCallOut[0].Apttus__Contract_End_Date__c;
                  }
                  if (newEffectiveDate.value) {
                    amendAgreementInsertList.Apttus__Amendment_Effective_Date__c =
                      newEffectiveDate.value;
                  } else {
                    amendAgreementInsertList.Apttus__Amendment_Effective_Date__c =
                      amendAgreementWebServiceCallOut[0].Apttus__Amendment_Effective_Date__c;
                  }
                  if (newTerms.value) {
                    amendAgreementInsertList.APTSMD_Amended_Terms__c =
                      newTerms.value;
                  }
                  amendAgreementInsertList.Apttus__Status_Category__c =
                    amendAgreementWebServiceCallOut[0].Apttus__Status_Category__c;

                  amendAgreementInsertList.Apttus__Status__c =
                    amendAgreementWebServiceCallOut[0].Apttus__Status__c;

                  //Inserting Amended Agreement
                  var result = sforce.connection.create([
                    amendAgreementInsertList,
                  ]);

                  //Clause
                  var amendAgreementInsertList = new sforce.SObject(
                    "Apttus__Agreement_Clause__c"
                  );

                  if (result[0].getBoolean("success")) {
                    //insert clause
                    //Clause
                    displayResult.push({
                      Id: result[0].id,
                      Name: amendAgreementWebServiceCallOut[0].Name,
                    });
                    amendAgreementClause.Apttus__Agreement__c = result[0].id;
                    amendAgreementClause.Apttus__Clause__c = "Amended Term";
                    amendAgreementClause.Apttus__Active__c = true;
                    amendAgreementClause.Apttus__Text__c = newTerms.value;
                    amendAgreementClause.Apttus__Action__c = "Inserted";
                    var clauseResult = sforce.connection.create([
                      amendAgreementClause,
                    ]);

                    //calling afterAmend Web API (This API establishes the relation between old Agreement and newly created Amended Agreement)

                    var afterAmendWebServiceCallOut = sforce.apex.execute(
                      "Apttus.ComplyWebService",
                      "afterAmend",
                      {
                        originalId: selectedAgreements[i].id,
                        amendmentId: result[0].id,
                      }
                    );

                    var relationshipList = sforce.apex.execute(
                      "Apttus.ComplyWebService",
                      "getAgreementChildRelationshipNamesForCloneAction",
                      {
                        cloneAgreementId: selectedAgreements[i].id,
                        action: "Amend",
                      }
                    );

                    var finalResult = sforce.apex.execute(
                      "Apttus.ComplyWebService",
                      "copyAgreementChildSObjects",
                      {
                        sourceAgreementId: selectedAgreements[i].id,
                        destAgreementId: result[0].id,
                        relationshipNames: relationshipList,
                      }
                    );
                  } else {
                    ShowErrors();
                    context.kendoGrid._progress &&
                      context.kendoGrid._progress(false);
                  }
                } catch (err) {
                  console.log(err);
                  ShowErrors();
                  context.kendoGrid._progress &&
                    context.kendoGrid._progress(false);
                }
              }

              Success();
              context.kendoGrid._progress && context.kendoGrid._progress(false);
              context.actionGrid.refresh();
            },
          },
        ];

        var values =
          "<table><tr><td>Agreement Start Date:</td><td><input id='newStartDate' type='date' value='" +
          startdatestr +
          "'/> </td></tr>" +
          "<tr><td>Agreement End Date:</td><td><input id='newEndDate' type='date' value='" +
          enddatestr +
          "'/></td></tr>" +
          "<tr><td>Amendment Effective Date:</td><td><input id='newEffectiveDate' type='date' value='" +
          effectivedatestr +
          "'/> </td></tr>" +
          "<tr><td>Amended Terms:</td><td><textarea rows='3' id='newTerms'></textarea> </td></tr></table>";

        kendoPopup.popupWithButtons(
          "Update Values for Amended Agreement(s):",
          values,
          buttons
        );
      },
    });
  }
);