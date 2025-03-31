global class APTSMD_AccountDetailsXAE {
    global String accId {get;set;}
    global String accountRecord {get;set;}
         
    global  APTSMD_AccountDetailsXAE(){
        accId = Apexpages.currentPage().getParameters().get('id');
        Account acc = [Select id,name from Account where id =: accId];
        accountRecord = JSON.serialize(acc.name);
    }

}