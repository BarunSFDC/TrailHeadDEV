trigger CreateEmailMessages on EmailMessage(before insert) {
	
    System.debug('------email message----'+Trigger.new[0].Subject);
    List<Email_Message__e > messages = new List<Email_Message__e>();
    Email_Message__e createEmailMessage = new Email_Message__e(
         Subject__c = Trigger.new[0].Subject
    ); 
    
    messages.add(createEmailMessage);
       
    List<Database.SaveResult> results = EventBus.publish(messages);
    
    Trigger.new[0].addError('Internal Error');

}