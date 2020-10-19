public class GoogleNewsLightning {

    @AuraEnabled
    public static string getName(id recId){
        System.debug('recordId'+recId);
        Account acc = [Select id , name FROM Account where id =: recId];
        String name = acc.name;
        name = name.toLowerCase();
        if(name.containsIgnoreCase('and family')){
            System.debug('Inside');
            name = name.replace('and family', '');
        }
            name = name.replace(' ','%20');
        return name;
        
    }
}