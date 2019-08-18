global class DailyLeadProcessor implements Schedulable {

    global void execute(SchedulableContext ctx) {
        List<Lead> lList = [Select Id, LeadSource from Lead where LeadSource = null ORDER BY Createddate DESC LIMIT 200];
        
        if(!lList.isEmpty()) {
			for(Lead l: lList) {
				l.LeadSource = 'Dreamforce';
			}
			update lList;
		}
    }
}