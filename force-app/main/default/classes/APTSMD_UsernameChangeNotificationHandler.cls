public class APTSMD_UsernameChangeNotificationHandler {
        
    @future(callout=true)
    public static void sendEmailToApttusLab(string oldusername,string newusername,Id orgId){ 
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
        message.setSenderDisplayName('Conga Lab');
        message.toAddresses = new String[] { 'sfdcmdo@conga.com' }; 
        message.subject = 'Username has been changed for the Org: '+orgId;
        message.htmlBody = 'Hi Team, <br><br>The username for the Org: '+orgId+' has been changed from '+oldusername+ ' to '+newusername+'. <br><br>Regards,<br>Conga';
        
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                 Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } 
        
        else {
            System.debug('The email failed to send: '
                  + results[0].errors[0].message);
        }
        
    }      
    
}