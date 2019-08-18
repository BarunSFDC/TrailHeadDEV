public class NewCaseListController {

    public List<Case> getNewCases(){
        return [SELECT Id,CaseNumber From Case WHERE Status = 'New'];
    }
}