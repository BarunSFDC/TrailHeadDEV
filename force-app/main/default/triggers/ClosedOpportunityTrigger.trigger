/*
# @description: Create a task to any opportunity inserted or updated with the stage of 'Closed Won'. 
# 				The task's subject must be 'Follow Up Test Task'.	
*/

trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {

	List<Task> taskList = new List<Task>();
    
    // In case of insert
    if(Trigger.isInsert){
        for(Opportunity opp : Trigger.New){
            System.debug('--opp.StageName---'+opp.StageName);
            if(opp.StageName == 'Closed Won'){
                
                //create a task for the Opportunity
                taskList.add(createTask(opp.Id));
                
            }
        }
    }
    
    // In case of update
    if(Trigger.isUpdate){
        for(Opportunity opp : Trigger.New){
            System.debug('--opp.StageName--update-'+opp.StageName);
            if(opp.StageName != Trigger.oldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won'){
                
                //create a task for the Opportunity
                taskList.add(createTask(opp.Id));
                
            }
        }
    }
    
    System.debug('--taskList-'+taskList.size());
    if(Schema.sObjectType.Task.isCreateable()){
        if(taskList.size() > 0){
        	
            // Insert tasks
            insert taskList; 
        }
    }
    

	// create a task    
    private Task createTask(Id oppId){
        
        Task newTask = new Task(
            Description = 'Opportunity closed won',
            Priority = 'Normal', 
            Status = 'In Progress', 
            Subject = 'Follow Up Test Task', 
            WhatId = oppId
        ); 

		return newTask;        
    }
}