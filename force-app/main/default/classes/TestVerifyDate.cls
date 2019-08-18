@isTest
private class TestVerifyDate {
    
    @isTest static void checkWithin30DaysTest() {
        
        Date date1 = Date.today();
        Date nextMontStartDate = date1.addMonths(1);
        Date nextMonthStartDate = nextMontStartDate.toStartOfMonth();
        nextMonthStartDate = nextMonthStartDate.addDays(-1);
        
        Integer daysBetween = date1.daysBetween(nextMonthStartDate) - 1;
        Date date2 = date1.addDays(daysBetween);
        
        Date returnDate = VerifyDate.CheckDates(date1, date2);
        
        System.assertEquals(returnDate, date2);
        
    }
    
    @isTest static void checkMoreThan30DaysTest() {
        
        Date date1 = Date.today();
        Date date2 = date1.addDays(35);
        
        Date returnDate = VerifyDate.CheckDates(date1, date2);
        
        Date nextMontStartDate = date1.addMonths(1);
        Date nextMonthStartDate = nextMontStartDate.toStartOfMonth();
        Date currentMonthEndDate = nextMonthStartDate.addDays(-1);
        
        System.assertEquals(returnDate, currentMonthEndDate);
        
    }

}