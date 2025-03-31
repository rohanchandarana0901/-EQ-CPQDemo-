/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex class designed to migrate KIRA projects into salesforce for CLM Intelligent Import
*
* This class is a controller for APTS_IDEInitialMigration Visualforce page
* Calls KIRA Rest APIs to retrieve project details and it's template/provisions.
* Creates records in Intelligent imports objects related to KIRA project selected by user. 
* Creates correct mappings correspodning to KIRA projects.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chetan Patel   <cpatel@apttus.com>
* @modifiedBy     Chetan Patel   <cpatel@apttus.com>
* @maintainedBy   Chetan Patel   <cpatel@apttus.com>
* @lastestVersion 1.9
* @created        12/16/2019
* @lastModified   03/27/2020
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class APTS_IDEInitialMigrationController {
    
    public boolean isimportSettingExists {get; set;}
    public static boolean isimportSettingCreated;
    public static string kiraEndPoint;
    public static string sToken;
    public static map<string, Apttus__IDEProvision__c> mapIDEProvision;
    public static map<string, Apttus__IDEProvision__c> mapIDEProvisionId;
    public static string importSettingJSON {get;set;}
    public string lstProjectsJSON {get;set;}
    public string selectedRecordTypeJSON {get; set;}
    
    static final string IDE_NAME = 'KIRA';
    
    static {
        try{
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
            List<Apttus__IDEProvision__c> lstAvailableProvisions =  [SELECT id,name,Apttus__IDEName__c,Apttus__FieldNumber__c,Apttus__Description__c,APTS_TemplateReferenceId__c,
                                                                      APTS_BaseObject__c,APTS_MetaDataFieldId__c,APTS_Provision_Type__c
                                                                      FROM Apttus__IDEProvision__c
                                                                      WHERE Apttus__Active__c = true
                                                                      order by Apttus__FieldNumber__c];
            mapIDEProvision = new map<string, Apttus__IDEProvision__c>();
            mapIDEProvisionId = new map<string, Apttus__IDEProvision__c>();
            for(Apttus__IDEProvision__c pro : lstAvailableProvisions){
                mapIDEProvision.put(pro.Apttus__FieldNumber__c,pro);
                mapIDEProvisionId.put(pro.id,pro);
            }
            
        }catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    
    public APTS_IDEInitialMigrationController(){

        lstProjectsJSON = JSON.serialize(lstProjectsJSON);
        selectedRecordTypeJSON= JSON.serialize(selectedRecordTypeJSON);
        if(isimportSettingCreated){
            isimportSettingExists=true;
            string endpoint = kiraEndPoint + 'projects?fields=project_id&fields=project_name';
            string response = callKiraAPIs('','GET',endpoint);
            set<string> setProjectIds = new set<String>();
            set<string> setRecordTypes = new set<String>();
            if(response!='FAILED'){
                for(Apttus__IDEMapProjectRecordType__c proj : [select id,name,Apttus__ProjectId__c,Apttus__RecordTypeName__c from Apttus__IDEMapProjectRecordType__c]){
                    setProjectIds.add(proj.Apttus__ProjectId__c);
                    setRecordTypes.add(proj.Apttus__RecordTypeName__c);
                }
                
                List<projectWrapper> lstProjects = new List<projectWrapper>();
                List<Object> meta = (List<Object>) JSON.deserializeUntyped(response);
                
                for (Object obj : meta) {
                    
                    Map<String, Object> myMaps = (Map<String, Object>)obj;
                    Integer projectId = ((Integer)myMaps.get('project_id'));
                    string projectName = ((string)myMaps.get('project_name'));
                    projectWrapper pw = new projectWrapper();
                    Apttus__IDEMapProjectRecordType__c project = new Apttus__IDEMapProjectRecordType__c();
                    if(projectName=='')
                        projectName = 'Untitled ' + String.valueOf(projectId);
                    project.Name =  projectName;
                    project.Apttus__ProjectId__c = String.valueOf(projectId);
                    //project.Apttus__RecordTypeName__c='RevRec';
                    pw.name= projectName;
                    pw.project = project;
                    pw.isSelected = false;
                    if(!setProjectIds.contains(project.Apttus__ProjectId__c))
                        lstProjects.add(pw);
                }
                
                if(lstProjects != null && lstProjects.size()>0){
                    lstProjectsJSON = JSON.serialize(lstProjects);
                }
                List<RecordType> lstAgreementRecordTypes = new List<RecordType>();
               lstAgreementRecordTypes = [select Id,Name from RecordType where sObjectType='Apttus__APTS_Agreement__c' and name NOT in :setRecordTypes];
               if(lstAgreementRecordTypes !=null && lstAgreementRecordTypes.size()>0)
                    selectedRecordTypeJSON = JSON.serialize(lstAgreementRecordTypes);
                
            }
            
            
        }
        else
            isimportSettingExists=false;
    }
    
    @RemoteAction
    public static string createProject(string selectedProjectsJSON){
        
        try{
            projectWrapper selectedProjectsWrapper = (projectWrapper) JSON.deserialize(selectedProjectsJSON,projectWrapper.class);
            List<Apttus__IDEMapProjectRecordType__c> LstIDEMapProjectRecordType = new List<Apttus__IDEMapProjectRecordType__c>();
    
            //for(projectWrapper pw: lstSelectedProjectsWrapper)
            //    LstIDEMapProjectRecordType.add(pw.project);
            if(selectedProjectsWrapper != null && selectedProjectsWrapper.project !=null)
                 insert selectedProjectsWrapper.project;
            
            return JSON.serialize(selectedProjectsWrapper);
        }catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    
    @RemoteAction
    public static boolean createProvisionWithClauseFields(string IDEMapProjectRecordTypeJSON){
        
        try{
            Apttus__IDEMapProjectRecordType__c project = (Apttus__IDEMapProjectRecordType__c) JSON.deserialize(IDEMapProjectRecordTypeJSON,Apttus__IDEMapProjectRecordType__c.class);
            List<Apttus__IDEMapProvisionRecordType__c> lstIDEMapProvisionRecordType = new List<Apttus__IDEMapProvisionRecordType__c>();
            List<Apttus__IDEMapClauseProvision__c> lstClause = new List<Apttus__IDEMapClauseProvision__c>();
            List<Apttus__IDEMapFieldProvision__c> lstField = new List<Apttus__IDEMapFieldProvision__c>();
            
            //for (Apttus__IDEMapProjectRecordType__c project : LstIDEMapProjectRecordType) {
                    System.debug('>>>>>>>>>>>>' + project.Name);
                    map<string,string> mapFields = getPrjectTemplate(project.Apttus__ProjectId__c);
                    
                    if(mapFields!= null && mapFields.keySet().size()>0){
                    
                        for(string s : mapFields.keySet()){
                            
                            Apttus__IDEMapProvisionRecordType__c provision = new Apttus__IDEMapProvisionRecordType__c();
                            Apttus__IDEProvision__c IDEProvision = mapIDEProvision.get(s);
                            if(IDEProvision!=null){
                                provision.Name=mapFields.get(s);
                                provision.Apttus__IDEProvisionId__c = IDEProvision.Id;
                                provision.APTS_IDE_Map_Project_Record_Type__c=project.Id;
                                provision.Apttus__RecordTypeName__c=project.Apttus__RecordTypeName__c;
                                lstIDEMapProvisionRecordType.add(provision);
                                    
                            }
                        }
                        
                        insert lstIDEMapProvisionRecordType;
                        
                        for(Apttus__IDEMapProvisionRecordType__c provision : lstIDEMapProvisionRecordType){
                            
                             Apttus__IDEProvision__c IDEProvision = mapIDEProvisionId.get(provision.Apttus__IDEProvisionId__c);
                             if(IDEProvision.APTS_Provision_Type__c=='Clause'){
                                Apttus__IDEMapClauseProvision__c clause = new Apttus__IDEMapClauseProvision__c();
                                clause.Name = provision.Name;
                                clause.Apttus__TemplateReferenceId__c = IDEProvision.APTS_TemplateReferenceId__c;
                                clause.Apttus__IDEMapProvisionRecordTypeId__c = provision.Id;
                                lstClause.add(clause);
                             }
                             if(IDEProvision.APTS_Provision_Type__c=='Field'){
                                Apttus__IDEMapFieldProvision__c field = new Apttus__IDEMapFieldProvision__c();
                                field.Apttus__BaseObject__c = IDEProvision.APTS_BaseObject__c;
                                field.Apttus__MetaDataFieldId__c = IDEProvision.APTS_MetaDataFieldId__c;
                                field.Apttus__IDEMapProvisionRecordTypeId__c = provision.Id;
                                field.Name = provision.Name;
                                lstField.add(field);
                             }
                        }
                        insert lstClause;
                        insert lstField;
                    }
             //   }
            return true;
        }catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return false;
        }
    }
    
    public static string callKiraAPIs(String sInputJson, string method,string endpoint){
        
        String returnValue = '';
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
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                returnValue = 'FAILED';
            } 
            else {
                returnValue = response.getBody();
            }
            
            return returnValue;
        }catch(Exception e) {
            return 'FAILED';
        }
    }
    
    public static map<string,string> getPrjectTemplate(string projectId){
        
        try {
            map<string,string> mapFields = new map<string,string>();
            string endpoint = kiraEndPoint + 'projects/'+ projectId + '/templates?fields=template_id&fields=is_default&fields=fields&fields=template_name';
            string response = callKiraAPIs('','GET',endpoint);
            system.debug('>>>>>> get template response  >>>>>');
            system.debug(response);
            List<Integer> lstTemplateIds= new List<Integer>();
            if(response!='FAILED'){
                List<Object> meta = (List<Object>) JSON.deserializeUntyped(response);
                for (Object obj : meta) {
                    Map<String, Object> myMaps = (Map<String, Object>)obj;
                    boolean isDefault = (boolean)myMaps.get('is_default');
                    if(isDefault){
                        List<Object> fields = (List<Object>)myMaps.get('fields');
                        for (Object f : fields) {
                            
                            Map<String, Object> field = (Map<String, Object>)f;
                            string fieldId = String.ValueOf(field.get('field_id'));
                            string fieldName = ((String)field.get('field_name'));
                            mapFields.put(fieldId,fieldName);
                        }
                    }
                }
            }
            system.debug('>>>>>> mapFields  >>>>>');
            system.debug(JSON.serialize(mapFields));
            return mapFields;
            
        }catch(Exception e) {
            return null;
        }
    }
    
    public class projectWrapper {
        
        public boolean isSelected {get;set;}
        public Apttus__IDEMapProjectRecordType__c project {get;set;}
        public string name {get;set;}
        public projectWrapper(){
            
            project = new Apttus__IDEMapProjectRecordType__c();
        }
    }

}