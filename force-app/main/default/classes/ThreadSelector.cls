public with sharing class ThreadSelector {

    public static Thread__c getThread(Id threadId) {
        return [
                SELECT Id,
                        Name,
                        External_Id__c,
                        Model__c,
                        Status__c,
                        Run_Id__c,
                        Ended_At__c,
                (
                        SELECT Id,
                                Thread__c,
                                External_Id__c,
                                Name,
                                Type__c,
                                Body__c,
                                CreatedById,
                                CreatedBy.Name,
                                CreatedBy.Alias,
                                CreatedDate,
                                Function_Correction__c,
                                Feedback__c
                        FROM Events__r
                        ORDER BY CreatedDate ASC
                        LIMIT 500
                )
                FROM Thread__c
                WHERE Id =: threadId
        ];
    }

    public static Thread_Event__c getThreadEvent(Id threadId) {
        return [
                SELECT Id,
                        Thread__c,
                        External_Id__c,
                        Name,
                        Type__c,
                        Body__c,
                        CreatedById,
                        CreatedBy.Name,
                        CreatedBy.Alias,
                        CreatedDate,
                        Function_Correction__c,
                        Feedback__c
                FROM Thread_Event__c
                WHERE Id =: threadId
                LIMIT 1
        ];
    }

    public static Thread_Event__c[] getThreadEvents(Id[] threadIds) {
        return [
                SELECT Id,
                        Thread__c,
                        External_Id__c,
                        Name,
                        Type__c,
                        Body__c,
                        CreatedById,
                        CreatedBy.Name,
                        CreatedBy.Alias,
                        CreatedDate,
                        Function_Correction__c,
                        Feedback__c
                FROM Thread_Event__c
                WHERE Id IN :threadIds
        ];
    }
}