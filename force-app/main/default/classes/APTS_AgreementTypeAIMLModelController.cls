/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex class designed to manage KIRA projects from salesforce for CLM Intelligent Import
*
* This class is a controller for APTS_AgreementTypeAIMLModel Visualforce page
* Calls KIRA Rest APIs to retrieve/update project details and it's template/provisions.
* Creates/updates records in objects related to intelligent import functionality to 
* Maintains correct mappings correspodning to KIRA projects.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chetan Patel   <cpatel@apttus.com>
* @modifiedBy     Chetan Patel   <cpatel@apttus.com>
* @maintainedBy   Chetan Patel   <cpatel@apttus.com>
* @lastestVersion 1.9
* @created        12/16/2019
* @lastModified   03/27/2020
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.9            cpatel@apttus.com
* 03/27/2020      Commented 2 lines which adds available provisions to removal list in save method to 
*                 prevent kira api failure due to large no of fields gettting added to removal list.
* 03/27/2020      Removed logic related to obligation reference
* 03/30/2020      Added new delete action button to delete project. 
*                 It deletes project in kira as well as all related entires in salesforce
* 04/13/2020      Deleting all existing  clauseprovision amd fieldprovision object records and creating new one
*                 everytime changes made in project in save method. line 493
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class APTS_AgreementTypeAIMLModelController {

    public Apttus__IDEMapProjectRecordType__c IDEMapProjectRecordType { get; set; }
    public string selectedRecordTypeJSON {get; set;}
    public string LstIDEMapProjectRecordTypeJSON {get; set;}
    public String IDEMapProjectRecordTypeId {get; set;}
    public List<ProvisonWrapper> lstProvisonWrapper {get; set;}
    public string lstProvisonWrapperJSON {get; set;}
    public string IDEMapProjectRecordTypeJSON {get; set;}
    public List<SelectOption> recordTypes {get; set;}
    public string keyPrefix {get; set;}
    public boolean isimportSettingExists {get; set;}
    public static boolean isimportSettingCreated;
    public static string kiraEndPoint;
    public static string sToken;
    public static boolean enableDelete {get; set;}
    public string agreementFieldsJSON {get;set;}
    public string templatesJSON {get;set;}
    public string provisionTypeJSON {get;set;}
    
    static final string IDE_NAME = 'KIRA';
    
    static {
        
        List<APTS_Intelligent_Import_Settings__c> lstImportSettings = new List<APTS_Intelligent_Import_Settings__c>();
        lstImportSettings = [select id,name,APTS_IDE_Service_URL__c,APTS_Token__c,APTS_Additional_Setting__c 
                             from APTS_Intelligent_Import_Settings__c 
                             where APTS_active__c=true 
                             and Name=:IDE_NAME 
                             limit 1];
        if(lstImportSettings !=null && lstImportSettings.size()>0){
            
            string version;
            if(!String.isBlank(lstImportSettings[0].APTS_Additional_Setting__c) && !String.isBlank(lstImportSettings[0].APTS_IDE_Service_URL__c) && !String.isBlank(lstImportSettings[0].APTS_Token__c)){
                
                Map<String, Object> mapResponseJSON = (Map<String, Object>) JSON.deserializeUntyped(lstImportSettings[0].APTS_Additional_Setting__c);
                if(mapResponseJSON.get('Version') != null)
                    version = String.valueOf(mapResponseJSON.get('Version'));
                else
                    version='v1';
                if(mapResponseJSON.get('enableDelete') != null)
                   enableDelete  = Boolean.valueOf(mapResponseJSON.get('enableDelete'));
                else
                    enableDelete=false;
                
                kiraEndPoint=lstImportSettings[0].APTS_IDE_Service_URL__c + '/'+version+'/';
                sToken=lstImportSettings[0].APTS_Token__c;
                system.debug('>>>> endpoint >>>>' + kiraEndPoint);
                isimportSettingCreated=true;
            }else{
                isimportSettingCreated=false;
            }
            
        }else{
            isimportSettingCreated=false;
        }
    }
    
    public APTS_AgreementTypeAIMLModelController(ApexPages.StandardController stdController){
        
        selectedRecordTypeJSON='none';
        lstProvisonWrapperJSON='none';
        keyPrefix='none';
        IDEMapProjectRecordTypeJSON='none';
        LstIDEMapProjectRecordTypeJSON='none';
        
        if(isimportSettingCreated){
                
                map<string,string> mapProvisionDesc = new map<string,string>();
                string endpoint = kiraEndPoint + 'fields?fields=description&fields=field_name&fields=is_custom&fields=field_id';
                string kiraProvisionDetailsJSON = callKiraAPIs('','GET',endpoint);
                
                if(!kiraProvisionDetailsJSON.contains('Kira callout failed')){
                    List<KiraProvisonDetails> lstKiraProvisonDetailsWrapper = (List<KiraProvisonDetails>) JSON.deserialize(kiraProvisionDetailsJSON,List<KiraProvisonDetails>.class);
                    for(KiraProvisonDetails pkr : lstKiraProvisonDetailsWrapper)
                        mapProvisionDesc.put(pkr.field_id,pkr.description);
                }
                isimportSettingExists=true;
                IDEMapProjectRecordTypeId = apexpages.currentpage().getparameters().get('id');
                List<Apttus__IDEMapProjectRecordType__c> LstIDEMapProjectRecordType = new List<Apttus__IDEMapProjectRecordType__c>();
                List<Apttus__IDEProvision__c> lstAvailableProvisions = new List<Apttus__IDEProvision__c>();
                lstProvisonWrapper = new List<ProvisonWrapper>();
                map<String,Apttus__IDEMapProvisionRecordType__c> mapProvisionRecordType = new map<String,Apttus__IDEMapProvisionRecordType__c>();
                
                LstIDEMapProjectRecordType = [select id,name,Apttus__ProjectId__c,Apttus__RecordTypeName__c,OwnerId 
                                              from Apttus__IDEMapProjectRecordType__c];
                LstIDEMapProjectRecordTypeJSON = JSON.serialize(LstIDEMapProjectRecordType);
                Schema.DescribeSObjectResult r = Apttus__IDEMapProjectRecordType__c.sObjectType.getDescribe();
                keyPrefix = r.getKeyPrefix();
                if(IDEMapProjectRecordTypeId != null){
                        
                    for(Apttus__IDEMapProjectRecordType__c project : LstIDEMapProjectRecordType){
                        if(project.id==IDEMapProjectRecordTypeId)
                            IDEMapProjectRecordType = project;
                            
                    }
                    
                }else {
                    Organization org= [Select id from Organization limit 1];
                    String initials = UserInfo.getFirstName().substring(0,1) + UserInfo.getLastName().substring(0,1);
                    IDEMapProjectRecordType = new Apttus__IDEMapProjectRecordType__c();
                    IDEMapProjectRecordType.Name='SE_' + initials + '_' + org.Id;
                }
               
               lstAvailableProvisions =  [SELECT id,name,Apttus__IDEName__c,Apttus__FieldNumber__c,Apttus__Description__c,APTS_TemplateReferenceId__c,
                                          APTS_BaseObject__c,APTS_MetaDataFieldId__c,APTS_Provision_Type__c
                                          FROM Apttus__IDEProvision__c
                                          WHERE Apttus__Active__c = true
                                          AND  Apttus__IDEName__c=:IDE_NAME];
        
                for(Apttus__IDEMapProvisionRecordType__c item :[select id,APTS_IDE_Map_Project_Record_Type__c,name,Apttus__IDEProvisionId__c,Apttus__IDEProvisionId__r.name,Apttus__RecordTypeName__c,  Apttus__Description__c from Apttus__IDEMapProvisionRecordType__c where (Apttus__IDEProvisionId__r.Apttus__IDEName__c=:IDE_NAME and  Apttus__RecordTypeName__c != null and Apttus__RecordTypeName__c=:IDEMapProjectRecordType.Apttus__RecordTypeName__c)])
                        mapProvisionRecordType.put(item.Apttus__IDEProvisionId__c,item);
                
                List<Apttus__APTS_Template__c> lstTemplates = [SELECT ID,Name,Apttus__ReferenceId__c from Apttus__APTS_Template__c where Apttus__IsActive__c=true
                                                    AND Apttus__Type__c='Clause'];
                templatesJSON = JSON.serialize(lstTemplates);                                    
                List<String> agreementFields = getAgreementfields();
                agreementFieldsJSON = JSON.serialize(agreementFields);
                List<String> provisionType = getProvisionTypePickListValues();
                provisionTypeJSON = JSON.serialize(provisionType);
                
                for(Apttus__IDEProvision__c item : lstAvailableProvisions){
                    
                    ProvisonWrapper pw = new ProvisonWrapper();
                    pw.provisionNumber = item.Apttus__FieldNumber__c;
                    pw.IDEProvisionWrapper = item;
                    if(mapProvisionRecordType.containsKey(item.Id)){
                        pw.isSelected = true;
                        pw.IDEMapProvisionRecordTypeWrapper = mapProvisionRecordType.get(item.Id);
                        pw.name = mapProvisionRecordType.get(item.Id).name;
                        
                    }else{
                        pw.isSelected = false;
                        Apttus__IDEMapProvisionRecordType__c tmpIDEMapProvisionRecordType= new Apttus__IDEMapProvisionRecordType__c();
                        tmpIDEMapProvisionRecordType.name = item.Apttus__Description__c;
                        pw.name =item.Apttus__Description__c;
                        tmpIDEMapProvisionRecordType.Apttus__IDEProvisionId__c = item.id;
                        tmpIDEMapProvisionRecordType.Apttus__RecordTypeName__c = IDEMapProjectRecordType.Apttus__RecordTypeName__c;
                        pw.IDEMapProvisionRecordTypeWrapper = tmpIDEMapProvisionRecordType;
                        
                    }
                    pw.description = mapProvisionDesc.get(item.Apttus__FieldNumber__c)!=null ? mapProvisionDesc.get(item.Apttus__FieldNumber__c):pw.name;
                    lstProvisonWrapper.add(pw);
                }
               
                lstProvisonWrapperJSON = JSON.serialize(lstProvisonWrapper);
                IDEMapProjectRecordTypeJSON = JSON.serialize(IDEMapProjectRecordType);
                
               List<RecordType> lstAgreementRecordTypes = new List<RecordType>();
               lstAgreementRecordTypes = [select Id,Name from RecordType where sObjectType='Apttus__APTS_Agreement__c'];
               if(lstAgreementRecordTypes !=null && lstAgreementRecordTypes.size()>0)
                    selectedRecordTypeJSON = JSON.serialize(lstAgreementRecordTypes);
                          
        }else{
            isimportSettingExists=false;
        }
        
    }
    
    private List<String> getProvisionTypePickListValues(){
       List<String> pickListValuesList= new List<String>();
        List<Schema.PicklistEntry> ple = Apttus__IDEProvision__c.APTS_Provision_Type__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    private List<String> getAgreementfields(){
        SObjectType ideProvisionType = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c');
        Schema.DescribeSObjectResult descSOResult =  ideProvisionType.getDescribe();
        
        Map<String,Schema.SObjectField> mfields = descSOResult.fields.getMap();
        List<String> mfieldList = new List<String>();
        for(Schema.SObjectField sfield : mfields.Values()) {
           mfieldList.add(''+sfield);
        }
        return mfieldList;
    }
    @RemoteAction
    public static string save(string IDEMapProjectRecordTypeJSON, string selectedProvisionsJSON,string availableProvisionsJSON,string removedProvisionsJSON){
        string returnValue='';
        string response='';
        string endpoint='';
        string sInputJson='';
        String projectId='';
        set<string> defaultFields = new set<string>();
        
        try{
        
            Apttus__IDEMapProjectRecordType__c IDEMapProjectRecordType = (Apttus__IDEMapProjectRecordType__c)JSON.deserialize(IDEMapProjectRecordTypeJSON, Apttus__IDEMapProjectRecordType__c.class);
            List<ProvisonWrapper> lstSelectedProvisonWrapper = (List<ProvisonWrapper>) JSON.deserialize(selectedProvisionsJSON,List<ProvisonWrapper>.class);
            List<ProvisonWrapper> lstAvailableProvisonWrapper = (List<ProvisonWrapper>) JSON.deserialize(availableProvisionsJSON,List<ProvisonWrapper>.class);
            List<ProvisonWrapper> lstRemovedProvisonWrapper = (List<ProvisonWrapper>) JSON.deserialize(removedProvisionsJSON,List<ProvisonWrapper>.class);

            if(IDEMapProjectRecordType.Id==null){
                    
                endpoint = kiraEndPoint + 'projects';
                sInputJson='{"project_name": "'+IDEMapProjectRecordType.name+'","client_info": "'+userinfo.getName()+'","project_info": "' +IDEMapProjectRecordType.name + '","default_template_name": "'+ IDEMapProjectRecordType.name + ' Template"}';
                system.debug('>>>>>> sInputJson >>>>>');
                system.debug(sInputJson);
                response = callKiraAPIs(sInputJson,'POST',endpoint);
                system.debug('>>>>>> createNewProj response >>>>>' + response);
                if(!response.contains('Kira callout failed')){
                    Map<String, Object> mapResponseJSON = (Map<String, Object>) JSON.deserializeUntyped(response);
                    projectId = String.valueOf(mapResponseJSON.get('project_id'));
                    system.debug('>>>>>> projectId >>>>>'+ projectId);
                    IDEMapProjectRecordType.Apttus__ProjectId__c=projectId;
                    string templateResponse=getPrjectTemplate(IDEMapProjectRecordType.Apttus__ProjectId__c);
                    system.debug('>>>>>> get templateresponse  >>>>>');
                    system.debug(templateResponse);
                    if(!templateResponse.contains('Kira callout failed')){
                    
                        List<Object> meta = (List<Object>) JSON.deserializeUntyped(templateResponse);
                        for (Object obj : meta) {
                            Map<String, Object> myMaps = (Map<String, Object>)obj;
                            boolean isDefault = (boolean)myMaps.get('is_default');
                            if(isDefault){
                                List<Object> fields = (List<Object>)myMaps.get('fields');
                                for (Object f : fields) {
                                
                                    Map<String, Object> myInnerMaps = (Map<String, Object>)f;
                                    string field = String.valueOf(myInnerMaps.get('field_id'));
                                    defaultFields.add(field);
                                }
                            }
                        }
                    }else{
                        returnValue=templateResponse;
                    }
                    
                }else{
                    returnValue=response;
                }
            }else{
                
                String encodedString = EncodingUtil.URLENCODE(IDEMapProjectRecordType.name,'UTF-8').replace('+', '%20');
                endpoint = kiraEndPoint + 'projects/'+ IDEMapProjectRecordType.Apttus__ProjectId__c + '/name?project_name='+encodedString;
                response = callKiraAPIs('','PUT',endpoint);
                
            }
            if(!response.contains('Kira callout failed')){
    
                response=getPrjectTemplate(IDEMapProjectRecordType.Apttus__ProjectId__c);
                system.debug('>>>>>> get template response  >>>>>');
                system.debug(response);
                
                if(!response.contains('Kira callout failed')){
                    List<Integer> lstTemplateIds = new List<Integer>();
                    List<Object> meta = (List<Object>) JSON.deserializeUntyped(response);
                    for (Object obj : meta) {
                        Map<String, Object> myMaps = (Map<String, Object>)obj;
                        boolean isDefault = (boolean)myMaps.get('is_default');
                        if(isDefault)
                            lstTemplateIds.add((Integer)myMaps.get('template_id'));
                    }
                    system.debug('>>>>>> lstTemplateIds  >>>>>');
                    system.debug(lstTemplateIds);
                    string addFields='';
                    string removeFields='';
                    if(lstTemplateIds!= null && lstTemplateIds.size()>0){
                
                        for(ProvisonWrapper pw : lstSelectedProvisonWrapper){
                            if(defaultFields.contains(pw.provisionNumber))
                                defaultFields.remove(pw.provisionNumber);
                            addFields = addFields + ',' + pw.provisionNumber;
                        }
                        
                        for(ProvisonWrapper pw : lstRemovedProvisonWrapper){
                            removeFields = removeFields + ',' + pw.provisionNumber;
                        }
                        for(string s : defaultFields)
                            removeFields = removeFields + ',' + s;
                         
                        addFields = addFields.removeStart(',');
                        removeFields = removeFields.removeStart(',');
                        sInputJson = '{"add_ids":['+ addFields +'],"remove_ids": ['+ removeFields + ']}';
                        system.debug('>>>>  sInputJson >>>>>>>>>>>>');
                        system.debug(JSON.serialize(removeFields));
                        
                        for(Integer i : lstTemplateIds){
                        
                            endpoint = kiraEndPoint + 'templates/'+ i +'/fields';
                            response = callKiraAPIs(sInputJson,'PUT',endpoint);
                            system.debug('>>>>>>>>>>>add remove fields >>>>>>>>>>');
                            system.debug(response);
                            if(!response.contains('Kira callout failed'))
                                returnValue=IDEMapProjectRecordType.Apttus__ProjectId__c;
                            else
                                returnValue= response;
                        }
                        
                    }
                }else{
                    returnValue= response;
                }
            }else{
                returnValue= response;
            }
        System.debug('returnvalue : >>>>> '+ returnValue);
        return returnValue;
        }catch(System.Exception e) {
            returnValue = 'Kira callout failed. ' + e.getMessage();
            System.debug(returnValue);
            return returnValue;
        }
    }
    
    @RemoteAction
    public static string deleteProject(string projectDelete){
        
        Apttus__IDEMapProjectRecordType__c IDEMapProjectRecordType = (Apttus__IDEMapProjectRecordType__c)JSON.deserialize(projectDelete, Apttus__IDEMapProjectRecordType__c.class);    
        string returnValue=null;
        string response=null;
        if(IDEMapProjectRecordType.Apttus__ProjectId__c!='210' && IDEMapProjectRecordType.Apttus__ProjectId__c!='1231'
            && IDEMapProjectRecordType.Apttus__ProjectId__c!='1233' && IDEMapProjectRecordType.Apttus__ProjectId__c!='1234'){
            string endpoint = kiraEndPoint + 'projects/'+ IDEMapProjectRecordType.Apttus__ProjectId__c;
            response =  callKiraAPIs('','DELETE',endpoint);
            system.debug('>>>>>> deleteProject API response >>>>>' + response);
        }else{
            response='Apttus lab project';
        }
        if(!response.contains('Kira callout failed')){
            
            List<Apttus__IDEMapClauseProvision__c> LstClauseProvisionDelete  = new List<Apttus__IDEMapClauseProvision__c>();
            List<Apttus__IDEMapFieldProvision__c> LstFieldProvisionDelete = new List<Apttus__IDEMapFieldProvision__c>();
            List<Apttus__IDEMapProvisionRecordType__c> LstIDEMapProvisionRecordTypeDelete = new List<Apttus__IDEMapProvisionRecordType__c>();
            
            LstClauseProvisionDelete = [select id from Apttus__IDEMapClauseProvision__c where  Apttus__IDEMapProvisionRecordTypeId__r.APTS_IDE_Map_Project_Record_Type__c=:IDEMapProjectRecordType.Id];
            LstFieldProvisionDelete = [select id from Apttus__IDEMapFieldProvision__c where  Apttus__IDEMapProvisionRecordTypeId__r.APTS_IDE_Map_Project_Record_Type__c=:IDEMapProjectRecordType.Id];
            LstIDEMapProvisionRecordTypeDelete = [select id from Apttus__IDEMapProvisionRecordType__c where APTS_IDE_Map_Project_Record_Type__c=:IDEMapProjectRecordType.Id];
            
            system.debug('>>> LstClauseProvisionDelete >>>' + LstClauseProvisionDelete.size());
            system.debug('>>> LstFieldProvisionDelete >>>' + LstFieldProvisionDelete.size());
            system.debug('>>> LstIDEMapProvisionRecordTypeDelete >>>' + LstIDEMapProvisionRecordTypeDelete.size());
            
            if(LstClauseProvisionDelete != null && LstClauseProvisionDelete.size()>0)
                delete LstClauseProvisionDelete;
            if(LstFieldProvisionDelete != null && LstFieldProvisionDelete.size()>0)
                delete LstFieldProvisionDelete;
            if(LstIDEMapProvisionRecordTypeDelete != null && LstIDEMapProvisionRecordTypeDelete.size()>0)
                delete LstIDEMapProvisionRecordTypeDelete;
            if(IDEMapProjectRecordType!=null)
                delete IDEMapProjectRecordType;
            
        }else{
            returnValue=response;
        }
        return returnValue;
    }
    
    @RemoteAction
    public static string performDMLOps(string projectUpsert,string selectedProvision, string availableProvision) {
        
        Apttus__IDEMapProjectRecordType__c IDEMapProjectRecordType = (Apttus__IDEMapProjectRecordType__c)JSON.deserialize(projectUpsert, Apttus__IDEMapProjectRecordType__c.class);    
        List<ProvisonWrapper> lstSelectedProvisonWrapper = (List<ProvisonWrapper>) JSON.deserialize(selectedProvision,List<ProvisonWrapper>.class);
        List<ProvisonWrapper> lstAvailableProvisonWrapper = (List<ProvisonWrapper>) JSON.deserialize(availableProvision,List<ProvisonWrapper>.class);
        
        List<Apttus__IDEMapProvisionRecordType__c> LstIDEMapProvisionRecordTypeInsert = new List<Apttus__IDEMapProvisionRecordType__c>();
        List<Apttus__IDEMapProvisionRecordType__c> LstIDEMapProvisionRecordTypeDelete = new List<Apttus__IDEMapProvisionRecordType__c>();
        List<Apttus__IDEMapClauseProvision__c> LstClauseProvisionInsert  = new List<Apttus__IDEMapClauseProvision__c>();
        List<Apttus__IDEMapClauseProvision__c> LstClauseProvisionDelete  = new List<Apttus__IDEMapClauseProvision__c>();
        List<Apttus__IDEMapFieldProvision__c> LstFieldProvisionInsert = new List<Apttus__IDEMapFieldProvision__c>();
        List<Apttus__IDEMapFieldProvision__c> LstFieldProvisionDelete = new List<Apttus__IDEMapFieldProvision__c>();
        
        List<Apttus__IDEMapClauseProvision__c> LstClauseProvision  = new List<Apttus__IDEMapClauseProvision__c>();
        List<Apttus__IDEMapFieldProvision__c> LstFieldProvision = new List<Apttus__IDEMapFieldProvision__c>();
        
        List<Apttus__IDEProvision__c> LstProvisionUpdate = new List<Apttus__IDEProvision__c>();

        try { 
            upsert IDEMapProjectRecordType;
            set<string> setIDEMapProvisionRecordTypeExisting = new set<string>();
            for(ProvisonWrapper pw : lstSelectedProvisonWrapper){
                    if(pw.IDEMapProvisionRecordTypeWrapper.Id == null){
                        pw.IDEMapProvisionRecordTypeWrapper.Apttus__RecordTypeName__c=IDEMapProjectRecordType.Apttus__RecordTypeName__c;
                        pw.IDEMapProvisionRecordTypeWrapper.APTS_IDE_Map_Project_Record_Type__c=IDEMapProjectRecordType.id;
                        LstIDEMapProvisionRecordTypeInsert.add(pw.IDEMapProvisionRecordTypeWrapper);
                        
                    }else{
                        setIDEMapProvisionRecordTypeExisting.add(pw.IDEMapProvisionRecordTypeWrapper.Id);
                    }
            }
            if(LstIDEMapProvisionRecordTypeInsert != null && LstIDEMapProvisionRecordTypeInsert.size()>0)
                insert LstIDEMapProvisionRecordTypeInsert;
            
            LstClauseProvision = [select id,Apttus__IDEMapProvisionRecordTypeId__c from Apttus__IDEMapClauseProvision__c where Apttus__IDEMapProvisionRecordTypeId__r.Apttus__IDEProvisionId__r.Apttus__IDEName__c=:IDE_NAME];
            LstFieldProvision = [select id,Apttus__IDEMapProvisionRecordTypeId__c from Apttus__IDEMapFieldProvision__c where Apttus__IDEMapProvisionRecordTypeId__r.Apttus__IDEProvisionId__r.Apttus__IDEName__c=:IDE_NAME];
            
            map<String,String> mapClause = new map<String,String>();
            map<String,String> mapField = new map<String,String>();
            
            for(Apttus__IDEMapClauseProvision__c clause : LstClauseProvision)
                mapClause.put(clause.Apttus__IDEMapProvisionRecordTypeId__c,clause.id);
            for(Apttus__IDEMapFieldProvision__c field : LstFieldProvision)
                mapField.put(field.Apttus__IDEMapProvisionRecordTypeId__c,field.id);
                
            system.debug('>>>>>> mapClause  ' + JSON.serialize(mapClause) );
            system.debug('>>>>>> mapField  ' + JSON.serialize(mapField) );
            
            for(ProvisonWrapper pw : lstSelectedProvisonWrapper){
                
                    system.debug('>>>>>>pw.IDEMapProvisionRecordTypeWrapper.Id :  ' + pw.IDEMapProvisionRecordTypeWrapper.Id );
                    if(!setIDEMapProvisionRecordTypeExisting.contains(pw.IDEMapProvisionRecordTypeWrapper.Id)){
                        
                        system.debug('>>>>>> inside insert clause :  ' + pw.IDEMapProvisionRecordTypeWrapper.Id );
                        if(pw.IDEProvisionWrapper.APTS_Provision_Type__c=='Clause'){
                        
                           Apttus__IDEMapClauseProvision__c clause = new Apttus__IDEMapClauseProvision__c();
                           clause.name = pw.IDEMapProvisionRecordTypeWrapper.name;
                           clause.Apttus__IDEMapProvisionRecordTypeId__c = pw.IDEMapProvisionRecordTypeWrapper.id;
                           clause.Apttus__TemplateReferenceId__c = pw.IDEProvisionWrapper.APTS_TemplateReferenceId__c;
                           system.debug('>>>>>> clause.Apttus__TemplateReferenceId__c  :  ' + clause.Apttus__TemplateReferenceId__c );
                           LstClauseProvisionInsert.add(clause);
                           
                        }
                        if(pw.IDEProvisionWrapper.APTS_Provision_Type__c=='Field'){
                            
                           Apttus__IDEMapFieldProvision__c field = new Apttus__IDEMapFieldProvision__c();
                           field.name = pw.IDEMapProvisionRecordTypeWrapper.name;
                           field.Apttus__IDEMapProvisionRecordTypeId__c = pw.IDEMapProvisionRecordTypeWrapper.id;
                           field.Apttus__MetaDataFieldId__c = pw.IDEProvisionWrapper.APTS_MetaDataFieldId__c;
                           field.Apttus__BaseObject__c = pw.IDEProvisionWrapper.APTS_BaseObject__c;
                           LstFieldProvisionInsert.add(field);
                        }
                        LstProvisionUpdate.add(pw.IDEProvisionWrapper);
                    }
                    
                    if(pw.IDEMapProvisionRecordTypeWrapper.Id != null && setIDEMapProvisionRecordTypeExisting.contains(pw.IDEMapProvisionRecordTypeWrapper.Id)){
                        
                        system.debug('>>>>>> inside insert clause :  ' + pw.IDEMapProvisionRecordTypeWrapper.Id );
                        if(pw.IDEProvisionWrapper.APTS_Provision_Type__c=='Clause'){
                        
                           Apttus__IDEMapClauseProvision__c clause = new Apttus__IDEMapClauseProvision__c();
                           
                           clause.name = pw.IDEMapProvisionRecordTypeWrapper.name;
                           clause.Apttus__IDEMapProvisionRecordTypeId__c = pw.IDEMapProvisionRecordTypeWrapper.id;
                           clause.Apttus__TemplateReferenceId__c = pw.IDEProvisionWrapper.APTS_TemplateReferenceId__c;
                           system.debug('>>>>>> clause.Apttus__TemplateReferenceId__c  :  ' + clause.Apttus__TemplateReferenceId__c );
                           system.debug('>>>>>> IDEMapProvisionRecordTypeWrapper ID  :  ' + pw.IDEMapProvisionRecordTypeWrapper.Id );
                           LstClauseProvisionInsert.add(clause);
                           
                        }
                        if(pw.IDEProvisionWrapper.APTS_Provision_Type__c=='Field'){
                            
                           Apttus__IDEMapFieldProvision__c field = new Apttus__IDEMapFieldProvision__c();
                           field.name = pw.IDEMapProvisionRecordTypeWrapper.name;
                           field.Apttus__IDEMapProvisionRecordTypeId__c = pw.IDEMapProvisionRecordTypeWrapper.id;
                           field.Apttus__MetaDataFieldId__c = pw.IDEProvisionWrapper.APTS_MetaDataFieldId__c;
                           field.Apttus__BaseObject__c = pw.IDEProvisionWrapper.APTS_BaseObject__c;
                           LstFieldProvisionInsert.add(field);
                        }
                        LstProvisionUpdate.add(pw.IDEProvisionWrapper);
                    }
                    
            }
            
            set<Id> setAvailableMapProvisionRecordType = new set<Id>();
            for(ProvisonWrapper pw : lstAvailableProvisonWrapper){
                system.debug('>>>>>> inside delete clause :  ' + pw.IDEMapProvisionRecordTypeWrapper.Id );
                if(pw.IDEMapProvisionRecordTypeWrapper.Id !=null){
                    LstIDEMapProvisionRecordTypeDelete.add(pw.IDEMapProvisionRecordTypeWrapper);
                    setAvailableMapProvisionRecordType.add(pw.IDEMapProvisionRecordTypeWrapper.Id);
                    
                }
            }
            
            LstClauseProvisionDelete = [select id from Apttus__IDEMapClauseProvision__c where  Apttus__IDEMapProvisionRecordTypeId__r.APTS_IDE_Map_Project_Record_Type__c=:IDEMapProjectRecordType.id];
            LstFieldProvisionDelete = [select id from Apttus__IDEMapFieldProvision__c where  Apttus__IDEMapProvisionRecordTypeId__r.APTS_IDE_Map_Project_Record_Type__c=:IDEMapProjectRecordType.id];
            
            system.debug('>>> LstIDEMapProvisionRecordTypeInsert >>>' + LstIDEMapProvisionRecordTypeInsert.size());
            system.debug('>>> LstClauseProvisionInsert >>>' + LstClauseProvisionInsert.size());
            system.debug('>>> LstFieldProvisionInsert >>>' + LstFieldProvisionInsert.size());
            
            system.debug('>>> LstIDEMapProvisionRecordTypeDelete >>>' + LstIDEMapProvisionRecordTypeDelete.size());
            system.debug('>>> LstClauseProvisionDelete >>>' + LstClauseProvisionDelete.size());
            system.debug('>>> LstFieldProvisionDelete >>>' + LstFieldProvisionDelete.size());
            
            system.debug('>>> LstProvisionUpdate >>>' + LstProvisionUpdate.size());
            
            
            if(LstClauseProvisionDelete != null && LstClauseProvisionDelete.size()>0)
                delete LstClauseProvisionDelete;
            if(LstFieldProvisionDelete != null && LstFieldProvisionDelete.size()>0)
                delete LstFieldProvisionDelete;
            if(LstIDEMapProvisionRecordTypeDelete != null && LstIDEMapProvisionRecordTypeDelete.size()>0)
                delete LstIDEMapProvisionRecordTypeDelete;
            if(LstProvisionUpdate != null && LstProvisionUpdate.size()>0)
                update LstProvisionUpdate; 
            if(LstClauseProvisionInsert != null && LstClauseProvisionInsert.size()>0)
                insert LstClauseProvisionInsert;
            if(LstFieldProvisionInsert != null && LstFieldProvisionInsert.size()>0)
                insert LstFieldProvisionInsert;
        }catch(System.Exception e) {
            
            return e.getMessage();
        }
        return IDEMapProjectRecordType.Id;
    }
    
    public static string getPrjectTemplate(string projectId){
        
        
        string endpoint = kiraEndPoint + 'projects/'+ projectId + '/templates?fields=template_id&fields=is_default&fields=fields&fields=template_name';
        return callKiraAPIs('','GET',endpoint);
    }
    
    public static string callKiraAPIs(String sInputJson, string method,string endpoint){
        
        String returnValue = 'success';
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);  //Your URI
            request.setMethod(method);
            request.setHeader('Authorization', 'Bearer ' + sToken);
            request.setHeader('Content-Type', 'application/json'); 
            request.setHeader('accept', 'application/json');
            if(sInputJson != null && sInputJson !='')
                request.setBody(sInputJson);
            
            HttpResponse response = http.send(request);
      
            if (response.getStatusCode() > 250) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                returnValue = 'Kira callout failed. ' + response.getStatusCode() + ' ' + response.getStatus();
            } 
            else {
                if(response.getBody()!=null && response.getBody()!='')
                    returnValue = response.getBody();
            }
            system.debug('---callKiraAPIs response :  ----' + returnValue);
                
            return returnValue;
        } 
        catch(System.Exception e) {
            return 'Kira callout failed. ' + e.getMessage();
        }
    }

    public class KiraProvisonDetails{
        public string field_id {get;set;}
        public string field_name {get;set;}
        public string  description {get;set;}
    }
    public class ProvisonWrapper{
    
        public boolean isSelected {get; set;}
        public Apttus__IDEMapProvisionRecordType__c IDEMapProvisionRecordTypeWrapper {get; set;}
        public Apttus__IDEProvision__c IDEProvisionWrapper {get;set;}
        public string name {get;set;}
        public string description {get;set;}
        public string provisionNumber {get;set;}
        public ProvisonWrapper(){
            
            isSelected = false;
            IDEMapProvisionRecordTypeWrapper = new Apttus__IDEMapProvisionRecordType__c();
            IDEProvisionWrapper = new Apttus__IDEProvision__c();
        }
        
    }
}