public with sharing class CTLocationTriggerHandler {
    public static void beforeInsert(List<Location__c> newRecords){
        for(Location__c locations : newRecords){
            locations.Status__c = 'Green';
        }
    }
    public static void beforeUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldMapRecords){
        for(Location__c locations : newRecords){
            if(locations.Status__c != oldMapRecords.get(locations.Id).Status__c){
                locations.Status_Update_Date__c = Date.today();
            }
        }
    }
    public static void afterUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordMap){
        Set<Id> statusChange = new Set<Id>();
        for(Location__c location : newRecords){
            if(location.Status__c == 'Red' && oldRecordMap.get(location.Id).Status__c != 'Red'){
                statusChange.add(location.Id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(statusChange);
        Set<Id> personIds = new Set<Id>();
        for (Location_Tracing__c trace : locationTraces) {
            personIds.add(trace.Person__c);
        }

        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Id pid : personIds) {
            peopleToUpdate.add(new Person__c(Id=pid, Health_Status__c='Yellow'));
        }

        if(peopleToUpdate.size() > 0){
            update peopleToUpdate;
        }
    }
}
