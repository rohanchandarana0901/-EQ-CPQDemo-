@isTest
private class APTS_AgreementTypeAIMLModelTest
{
    static testMethod void testAgreementTypeAIMLModel()
    {
        APTS_Intelligent_Import_Settings__c setting = new APTS_Intelligent_Import_Settings__c();
        
        setting.name = 'KIRA';
        setting.APTS_IDE_Service_URL__c='https://ca.app.kirasystems.com/platform-api';
        setting.APTS_Token__c='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzIjoiSmVSUDIwR0hOYk5GYmpXU1h5Y0VrRm5QIiwiZiI6Mzk3fQ.SUyjqr1gojxkPiam8wgWd3FEYFCp1C4YT94nOHBQFLk';
        setting.APTS_Additional_Setting__c='{"Version":"v1","DefaultProjectId" : 117}';
        setting.APTS_active__c=true;
        
        insert setting;
        
        Apttus__IDEMapProjectRecordType__c project = new Apttus__IDEMapProjectRecordType__c();
        project.Apttus__ProjectId__c = '100';
        project.Apttus__RecordTypeName__c = 'MSA';
        project.name='MSA';
        insert project;
        
        Apttus__IDEMapProjectRecordType__c project1 = new Apttus__IDEMapProjectRecordType__c();
        project1.Apttus__ProjectId__c = '100';
        project1.Apttus__RecordTypeName__c = 'MSA';
        project1.name='MSA';
        //insert project;
        
        
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
        
        Apttus__IDEMapProvisionRecordType__c IDEProvision = new Apttus__IDEMapProvisionRecordType__c();
        IDEProvision.APTS_IDE_Map_Project_Record_Type__c=project.id;
        IDEProvision.Apttus__IDEProvisionId__c=provision.id;
        IDEProvision.Apttus__RecordTypeName__c='MSA';
        IDEProvision.name='Assignment';
        insert IDEProvision;
        
        
        Apttus__IDEMapProvisionRecordType__c IDEProvision1 = new Apttus__IDEMapProvisionRecordType__c();
        IDEProvision1.APTS_IDE_Map_Project_Record_Type__c=project.id;
        IDEProvision1.Apttus__IDEProvisionId__c=provision1.id;
        IDEProvision1.Apttus__RecordTypeName__c='MSA';
        IDEProvision1.name='End Date';
        insert IDEProvision1;
        
        Apttus__IDEMapProvisionRecordType__c IDEProvision2 = new Apttus__IDEMapProvisionRecordType__c();
        IDEProvision2.APTS_IDE_Map_Project_Record_Type__c=project.id;
        IDEProvision2.Apttus__IDEProvisionId__c=provision1.id;
        IDEProvision2.Apttus__RecordTypeName__c='MSA';
        IDEProvision2.name='End Date';
        //insert IDEProvision1;
        
        Apttus__IDEMapProvisionRecordType__c IDEProvision3 = new Apttus__IDEMapProvisionRecordType__c();
        IDEProvision3.APTS_IDE_Map_Project_Record_Type__c=project.id;
        IDEProvision3.Apttus__IDEProvisionId__c=provision1.id;
        IDEProvision3.Apttus__RecordTypeName__c='MSA';
        IDEProvision3.name='End Date';
        
        Apttus__IDEMapClauseProvision__c clause = new Apttus__IDEMapClauseProvision__c();
        clause.name = IDEProvision.name;
        clause.Apttus__IDEMapProvisionRecordTypeId__c = IDEProvision.id;
        clause.Apttus__TemplateReferenceId__c = provision.APTS_TemplateReferenceId__c;
        insert clause;
        
        Apttus__IDEMapFieldProvision__c field = new Apttus__IDEMapFieldProvision__c();
        field.name = IDEProvision1.name;
        field.Apttus__IDEMapProvisionRecordTypeId__c = IDEProvision1.id;
        field.Apttus__MetaDataFieldId__c = provision1.APTS_MetaDataFieldId__c;
        field.Apttus__BaseObject__c = provision1.APTS_MetaDataFieldId__c;
        insert field;
        
        List<APTS_AgreementTypeAIMLModelController.ProvisonWrapper>  selectedProvisions = new List<APTS_AgreementTypeAIMLModelController.ProvisonWrapper>();
        List<APTS_AgreementTypeAIMLModelController.ProvisonWrapper>  availableProvisions = new List<APTS_AgreementTypeAIMLModelController.ProvisonWrapper>();
        List<APTS_AgreementTypeAIMLModelController.ProvisonWrapper>  removedProvisions = new List<APTS_AgreementTypeAIMLModelController.ProvisonWrapper>();

        APTS_AgreementTypeAIMLModelController.ProvisonWrapper wrapper = new APTS_AgreementTypeAIMLModelController.ProvisonWrapper();
        wrapper.isSelected = true;
        wrapper.IDEMapProvisionRecordTypeWrapper=IDEProvision;
        wrapper.IDEProvisionWrapper=provision;
        wrapper.name = IDEProvision.name;
        wrapper.provisionNumber = provision.Apttus__FieldNumber__c;
        
        APTS_AgreementTypeAIMLModelController.ProvisonWrapper wrapper1 = new APTS_AgreementTypeAIMLModelController.ProvisonWrapper();
        wrapper1.isSelected = false;
        wrapper1.IDEMapProvisionRecordTypeWrapper=IDEProvision1;
        wrapper1.IDEProvisionWrapper=provision1;
        wrapper1.name = IDEProvision1.name;
        wrapper1.provisionNumber = provision1.Apttus__FieldNumber__c;
        
        APTS_AgreementTypeAIMLModelController.ProvisonWrapper wrapper2 = new APTS_AgreementTypeAIMLModelController.ProvisonWrapper();
        wrapper2.isSelected = false;
        wrapper2.IDEMapProvisionRecordTypeWrapper=IDEProvision2;
        wrapper2.IDEProvisionWrapper=provision1;
        wrapper2.name = IDEProvision2.name;
        wrapper2.provisionNumber = provision1.Apttus__FieldNumber__c;
        
        APTS_AgreementTypeAIMLModelController.ProvisonWrapper wrapper3 = new APTS_AgreementTypeAIMLModelController.ProvisonWrapper();
        wrapper3.isSelected = false;
        wrapper3.IDEMapProvisionRecordTypeWrapper=IDEProvision3;
        wrapper3.IDEProvisionWrapper=provision1;
        wrapper3.name = IDEProvision3.name;
        wrapper3.provisionNumber = provision1.Apttus__FieldNumber__c;
        
        selectedProvisions.add(wrapper);
        selectedProvisions.add(wrapper2);
        availableProvisions.add(wrapper1);
        removedProvisions.add(wrapper3);
        
        
        System.Test.startTest();
        
        string IDEMapProjectRecordTypeJSON = JSON.serialize(project1);
        string selectedProvisionsJSON = JSON.serialize(selectedProvisions);
        string availableProvisionsJSON = JSON.serialize(availableProvisions);
        string removedProvisionsJSON = JSON.serialize(removedProvisions);
        
        PageReference pageRef = Page.APTS_AgreementTypeAIMLModel;
        System.Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        APTS_AgreementTypeAIMLModelController model = new APTS_AgreementTypeAIMLModelController(sc);
        system.Test.setMock(HttpCalloutMock.class, new APTS_AgreementTypeAIMLModelMock()); 
        
        string response = APTS_AgreementTypeAIMLModelController.save(IDEMapProjectRecordTypeJSON, selectedProvisionsJSON,availableProvisionsJSON,removedProvisionsJSON);
        string response1 = APTS_AgreementTypeAIMLModelController.performDMLOps(IDEMapProjectRecordTypeJSON, selectedProvisionsJSON,availableProvisionsJSON);
        
        IDEMapProjectRecordTypeJSON = JSON.serialize(project);
        pageRef.getParameters().put('id',project.id);
        System.Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(project);
        model = new APTS_AgreementTypeAIMLModelController(sc);
        
        response = APTS_AgreementTypeAIMLModelController.save(IDEMapProjectRecordTypeJSON, selectedProvisionsJSON,availableProvisionsJSON,removedProvisionsJSON);
        response1 = APTS_AgreementTypeAIMLModelController.performDMLOps(IDEMapProjectRecordTypeJSON, selectedProvisionsJSON,availableProvisionsJSON);
        System.Test.stopTest();        
        
        
        
    }
}