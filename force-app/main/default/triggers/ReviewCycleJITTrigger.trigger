trigger ReviewCycleJITTrigger on Apttus__ReviewCycle__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate && APTSMD_JITNotificationInput.isFirstTime) {
        APTSMD_JITNotificationInput.isFirstTime = false;
        for(Apttus__ReviewCycle__c p : Trigger.New) {
            system.debug('#### got a trigger for ' + p.Name);
            List<APTSMD_JITNotificationInput> inputs = new List<APTSMD_JITNotificationInput>();
            APTSMD_JITNotificationInput input = new APTSMD_JITNotificationInput();
            input.objectId = p.Id;
            input.objectName = 'reviewCycle';
            input.lookupResult = p;
            input.previousResult = Trigger.Old[0];

            inputs.add(input);
            if(System.IsBatch() == false && System.isFuture() == false && Test.isRunningTest() == false){
                APTSMD_MaxResolveQuery.resolveReferenceQuery(inputs);
            }
        }
    }
}