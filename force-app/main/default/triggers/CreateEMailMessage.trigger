trigger CreateEMailMessage on Email_Message__e (after insert) {
	
    System.debug('-------Message Details----'+Trigger.new[0].Subject__c);
    Account acc = new Account(Name = Trigger.new[0].Subject__c);
    Insert acc;
}