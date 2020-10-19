trigger TPPMeetingSlot on Meeting_Slot__c (before insert, before update) {
	try{
	    Map<Id,Meeting_Slot__c> oldObj = Trigger.oldMap;
	    if(Trigger.isBefore){
	        for(Meeting_Slot__c msRecord: Trigger.New){
	            Meeting_Slot__c oldRecord = new Meeting_Slot__c();
	            if(oldObj!=null && oldObj.size()>0)
	            	oldRecord = oldObj.get(msRecord.id);
	            
	            /* Time Validation Start */
	            String startTime = msRecord.Start_Time__c;
	            String endTime = msRecord.End_Time__c;
	            Integer shh = Integer.valueOf(startTime.split(':')[0]);
	            Integer smm = Integer.valueOf(startTime.split(':')[1].split(' ')[0].substring(0));
	            Integer ehh = Integer.valueOf(endTime.split(':')[0]);
	            Integer emm = Integer.valueOf(endTime.split(':')[1].split(' ')[0].substring(0));
	            if((startTime.contains('AM') && !endTime.contains('PM')) || (startTime.contains('PM') && !endTime.contains('AM'))){
	                if(((shh > ehh && shh != 12) || (ehh == 12 && shh < ehh)) || (shh == ehh && (smm > emm || smm == emm))){
	                    msRecord.Start_Time__c.addError('End time should be greater than Start time.');
	                }
	            }
	            /* Time Validation End */
	            
	            /* Slot Validation Start */
				Integer tempStartIndex = 0;
				Integer tempEndIndex = 0;
				Map<Integer, String> timeSlots = new Map<Integer,String>();
				timeSlots.put(1,'12:00 AM');
				timeSlots.put(2,'12:30 AM');
				timeSlots.put(3,'1:00 AM');
				timeSlots.put(4,'1:30 AM');
				timeSlots.put(5,'2:00 AM');
				timeSlots.put(6,'2:30 AM');
				timeSlots.put(7,'3:00 AM');
				timeSlots.put(8,'3:30 AM');
				timeSlots.put(9,'4:00 AM');
				timeSlots.put(10,'4:30 AM');
				timeSlots.put(11,'5:00 AM');
				timeSlots.put(12,'5:30 AM');
				timeSlots.put(13,'6:00 AM');
				timeSlots.put(14,'6:30 AM');
				timeSlots.put(15,'7:00 AM');
				timeSlots.put(16,'7:30 AM');
				timeSlots.put(17,'8:00 AM');
				timeSlots.put(18,'8:30 AM');
				timeSlots.put(19,'9:00 AM');
				timeSlots.put(20,'9:30 AM');
				timeSlots.put(21,'10:00 AM');
				timeSlots.put(22,'10:30 AM');
				timeSlots.put(23,'11:00 AM');
				timeSlots.put(24,'11:30 AM');
				timeSlots.put(25,'12:00 PM');
				timeSlots.put(26,'12:30 PM');
				timeSlots.put(27,'1:00 PM');
				timeSlots.put(28,'1:30 PM');
				timeSlots.put(29,'2:00 PM');
				timeSlots.put(30,'2:30 PM');
				timeSlots.put(31,'3:00 PM');
				timeSlots.put(32,'3:30 PM');
				timeSlots.put(33,'4:00 PM');
				timeSlots.put(34,'4:30 PM');
				timeSlots.put(35,'5:00 PM');
				timeSlots.put(36,'5:30 PM');
				timeSlots.put(37,'6:00 PM');
				timeSlots.put(38,'6:30 PM');
				timeSlots.put(39,'7:00 PM');
				timeSlots.put(40,'7:30 PM');
				timeSlots.put(41,'8:00 PM');
				timeSlots.put(42,'8:30 PM');
				timeSlots.put(43,'9:00 PM');
				timeSlots.put(44,'9:30 PM');
				timeSlots.put(45,'10:00 PM');
				timeSlots.put(46,'10:30 PM');
				timeSlots.put(47,'11:00 PM');
				timeSlots.put(48,'11:30 PM');
				for(Integer slotKey: timeSlots.keySet()){
				    if(timeSlots.get(slotKey) == startTime){
				        tempStartIndex = slotKey;
				    }
				    if(timeSlots.get(slotKey) == endTime){
				        tempEndIndex = slotKey;
				    }
				}
				List<String> tempStartCheckSlotList = new List<String>();
				List<String> tempEndCheckSlotList = new List<String>();
				for(Integer start = tempStartIndex; start < tempEndIndex; start++){
				    tempStartCheckSlotList.add(timeSlots.get(start));
				    tempEndCheckSlotList.add(timeSlots.get(start+1));
				}
				
				List<Meeting_Slot__c> overLapResult = [Select Start_Time__c, End_Time__c 
					                                        from Meeting_Slot__c 
					                                        where Meeting_Number__c =: msRecord.Meeting_Number__c AND
					                                        (Start_Time__c IN: tempStartCheckSlotList OR End_Time__c IN: tempEndCheckSlotList) AND id !=: msRecord.id ];
				System.debug('DildarLog: tempEndCheckSlotList - ' + tempEndCheckSlotList);
				System.debug('DildarLog: tempStartCheckSlotList - ' + tempStartCheckSlotList);
				System.debug('DildarLog: overLapResult - ' + overLapResult);
				
				/* Slot Validation End */
				
					                                        
	            if(overLapResult.size()>0){
	                if(Trigger.isUpdate && (oldRecord.Start_Time__c != msRecord.Start_Time__c || oldRecord.End_Time__c != msRecord.End_Time__c)){
	                    msRecord.addError('Selected slot is not available.');
	                }else if(Trigger.isInsert){
	                    msRecord.addError('Selected slot is not available.');
	                }                
	            }
	            if(Trigger.isUpdate && oldRecord.Meeting_Status__c != msRecord.Meeting_Status__c && msRecord.Meeting_Status__c == 'Booked'){
	                msRecord.Record_Owner__c = UserInfo.getUserId();
	            }
	        }
	    }
	}catch(Exception ex){
		System.debug('Exception @ TPP Meeting Slot: ' + ex);
	}
}