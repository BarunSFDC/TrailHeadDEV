@istest
public class AccountManagerTest {

    @isTest static void testGetAccount() {
        Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri = 'https://ctpnew-dev-ed.my.salesforce.com/services/apexrest/Accounts/'+recordId+'/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account thisAcc = AccountManager.getAccount();
        // Verify results
        System.assert(thisAcc != null);
        System.assertEquals('Test record', thisAcc.Name);
    }
    
    // Helper method
    static Id createTestRecord() {
        // Create test record
        Account accTest = new Account(
            Name='Test record');
        insert accTest;
        return accTest.Id;
    }     
}