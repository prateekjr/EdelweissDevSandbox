trigger UserTrigger on User (after insert,after update) {
    boolean createContact=false;
    List<User> newUser = trigger.new;
    List<String> listOfUsers = new List<String>();
    for(user u : newUser){
        listOfUsers.add(JSON.serialize(u));
    }
    if(Trigger.isInsert){
        createContact=true;
    }
    //Compared values here so that the future method is not called from DLRS
    if(Trigger.isUpdate){
        for (User user: Trigger.new) {
            User oldUser = Trigger.oldMap.get(user.ID);
            if(user.FirstName != oldUser.FirstName || user.LastName != oldUser.LastName ) {
                createContact=true;
            }
            
        }
    }
    if(createContact){
        UserContactCreation.createContact(listOfUsers);
    }
    
}