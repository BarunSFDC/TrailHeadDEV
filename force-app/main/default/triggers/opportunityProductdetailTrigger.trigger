trigger opportunityProductdetailTrigger on OpportunityLineItem (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        opportunityProductTriggerHandler.isAfterInsert(Trigger.new);
    }
    
        
}