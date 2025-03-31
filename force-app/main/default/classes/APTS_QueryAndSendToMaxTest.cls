@isTest
private class APTS_QueryAndSendToMaxTest {
    @IsTest
  private static void testMaxNotificationCallout() {
      APTS_MaxNotification notificationInfo = new APTS_MaxNotification();
      notificationInfo.NotificationTask = 'test';
      List<String> ui = new List<String>();
      ui.add('0053i000001Xn8NAAS');
      notificationInfo.UserIds = ui;
        
    Test.setMock(HttpCalloutMock.class, new APTS_MaxNotificationCalloutMock());
    Test.startTest();
      APTS_QueryAndSendToMax.sendRequest(JSON.serialize(notificationInfo , true));
    Test.stopTest();
  }
  
    @isTest 
    private static void notificationTest() {
        List<Opportunity> theOpps = new List<Opportunity>();
         for(Integer i=0;i<5;i++) {
            Opportunity q = new Opportunity();
            q.Name = 'Opp test'+i;
            q.StageName = 'Prospecting';
            q.CloseDate = date.today();
            q.OwnerId = '0053i000001Xn8NAAS';
            system.debug('######## adding opp with ownerId = ' + q.OwnerId);
            theOpps.add(q);
        }
        insert theOpps;
        
        APTSMD_NotificationObject ni = new APTSMD_NotificationObject();
        ni.query = 'SELECT Id,Name,OwnerId FROM Opportunity WHERE CloseDate = TODAY AND OwnerId = \'0053i000001Xn8NAAS\'';
        ni.fieldToSave = 'OwnerId';
        ni.notificationType = 'test';
        List<APTSMD_NotificationObject> niList = new List<APTSMD_NotificationObject>();
        niList.add(ni);
        
        APTS_QueryAndSendToMax smn = new APTS_QueryAndSendToMax();
        
        List<List<String>> result = APTS_QueryAndSendToMax.prepareNotification(niList);
        System.assertEquals('0053i000001Xn8NAAS',result[0][0]);
    }
}