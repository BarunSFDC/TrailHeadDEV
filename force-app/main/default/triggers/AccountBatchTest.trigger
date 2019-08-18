trigger AccountBatchTest on Account (after insert) {
    
    System.debug('Trigger Size---'+Trigger.New.size());
    System.debug('----First Record Name of the Batch--'+Trigger.New[0].Name);
    System.debug('----DML statements completed--'+Limits.getDMLStatements());
    
}