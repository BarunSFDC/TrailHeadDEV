public class LeadProcessor implements Database.Batchable<SObject>{ 
   
   public Database.QueryLocator start(Database.BatchableContext info){ 
       return Database.getQueryLocator('SELECT Id, LeadSource FROM LEAD');
   }    
       
   public void execute(Database.BatchableContext info, List<Lead> scope){
       
       for(Lead lead :scope){
           lead.LeadSource = 'Dreamforce';
       }
       
       update scope;
       
   }     
       
   public void finish(Database.BatchableContext info){
       System.debug('All Leads are updated to dreamforce--');
   }
       
}