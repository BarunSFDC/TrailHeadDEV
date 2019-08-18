trigger OnUserInfo on UserInfo__c (before insert) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert){
            Integer i=[select count() from UserInfo__c];          
            for(UserInfo__c cord:Trigger.new){        
                String fname=cord.First_Name__c.substring(0,2);
                String lname=cord.Last_Name__c.substring(0,2);
                String uname;
                String uid=cord.Email_Id__c;
                if(i>99){
                    Integer j=i/100;
                    uname=fname+lname+String.valueof(j);
                }else{
                    uname=fname+lname+String.valueof(i);
                }                  
                Blob pw = Blob.valueOf(uname);
                String encryptedPw = EncodingUtil.base64Encode(pw); 
                cord.password__c=encryptedPw;
                cord.Change_Password__c=true;      
                cord.UserId__c=uid;
            }
        }
    }     
     
}