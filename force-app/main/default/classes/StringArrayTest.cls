public class StringArrayTest {

    public static List<String> generateStringArray(Integer input){
        
        List<String> lstNames = new List<String>();
        for(Integer i=0; i< input; i++){
            String name = 'Test '+i;
            lstNames.add(name);
        }
        return lstNames;
    }
}