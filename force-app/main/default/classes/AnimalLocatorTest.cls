@IsTest
public class AnimalLocatorTest {
    @isTest
    public static void testAnimalLocator() {
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        String s =  AnimalLocator.getAnimalNameById(1);
        System.assertEquals('chicken', s);
    }

}