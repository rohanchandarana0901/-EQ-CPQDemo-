@isTest
private class APTS_IDEInitialMigrationTest {
    
    static testMethod void testInitialMigration()
    {
        APTS_Intelligent_Import_Settings__c setting = new APTS_Intelligent_Import_Settings__c();
        
        setting.name = 'KIRA';
        setting.APTS_IDE_Service_URL__c='https://ca.app.kirasystems.com/platform-api';
        setting.APTS_Token__c='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzIjoiSmVSUDIwR0hOYk5GYmpXU1h5Y0VrRm5QIiwiZiI6Mzk3fQ.SUyjqr1gojxkPiam8wgWd3FEYFCp1C4YT94nOHBQFLk';
        setting.APTS_Additional_Setting__c='{"Version":"v1","DefaultProjectId" : 117}';
        setting.APTS_active__c=true;
        
        insert setting;
        
        List<Apttus__IDEMapProjectRecordType__c> LstIDEMapProjectRecordType = new List<Apttus__IDEMapProjectRecordType__c>();
        
        Apttus__IDEMapProjectRecordType__c project = new Apttus__IDEMapProjectRecordType__c();
        project.Apttus__ProjectId__c = '100';
        project.Apttus__RecordTypeName__c = 'MSA';
        project.name='MSA';
        insert project;
        
        Apttus__IDEMapProjectRecordType__c project1 = new Apttus__IDEMapProjectRecordType__c();
        project1.Apttus__ProjectId__c = '101';
        project1.Apttus__RecordTypeName__c = 'NDA';
        project1.name='NDA';
        insert project1;
        
        LstIDEMapProjectRecordType.add(project);
        LstIDEMapProjectRecordType.add(project1);
        
        List<APTS_IDEInitialMigrationController.projectWrapper>  selectedProjects = new List<APTS_IDEInitialMigrationController.projectWrapper>();
        
        APTS_IDEInitialMigrationController.projectWrapper wrapper = new APTS_IDEInitialMigrationController.projectWrapper();
        wrapper.isSelected = true;
        wrapper.project=project;
        wrapper.name=project.name;
        
        APTS_IDEInitialMigrationController.projectWrapper wrapper1 = new APTS_IDEInitialMigrationController.projectWrapper();
        wrapper1.isSelected = false;
        wrapper1.project=project1;
        wrapper1.name=project.name;
        
        selectedProjects.add(wrapper);
        
        Apttus__IDEProvision__c provision = new Apttus__IDEProvision__c();
        provision.name='Assignment';
        provision.Apttus__IDEName__c='KIRA';
        provision.Apttus__Active__c=true;
        provision.Apttus__FieldNumber__c='4';
        provision.APTS_TemplateReferenceId__c='83f4dafc-3927-42d2-b55f-13068bfeccb8';
        insert provision;
        
        Apttus__IDEProvision__c provision1 = new Apttus__IDEProvision__c();
        provision1.name='End Date';
        provision1.Apttus__IDEName__c='KIRA';
        provision1.Apttus__Active__c=true;
        provision1.Apttus__FieldNumber__c='301';
        provision1.APTS_BaseObject__c='Apttus__APTS_Agreement__c';
        provision1.APTS_MetaDataFieldId__c='Apttus__Contract_End_Date__c';
        insert provision1;
        
        System.Test.startTest();
        
        PageReference pageRef = Page.APTS_IDEInitialMigration;
        System.Test.setCurrentPage(pageRef);
        System.Test.setMock(HttpCalloutMock.class, new APTS_AgreementTypeAIMLModelMock()); 
        
        APTS_IDEInitialMigrationController controller = new APTS_IDEInitialMigrationController();
        
        string selectedProjectsJSON = JSON.serialize(selectedProjects);
        string LstIDEMapProjectRecordTypeJSON = JSON.serialize(LstIDEMapProjectRecordType);
        
        APTS_IDEInitialMigrationController.createProject(selectedProjectsJSON);
        APTS_IDEInitialMigrationController.createProvisionWithClauseFields(LstIDEMapProjectRecordTypeJSON);
        
        System.Test.stopTest(); 
        
    }

}