public with sharing class ThreadEventWrapper {

    @AuraEnabled public String threadId { get; set; }
    @AuraEnabled public String externalId { get; set; }
    @AuraEnabled public String salesforceId { get; set; }
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public Actor actor { get; set; }
    @AuraEnabled public String type { get; set; }
    @AuraEnabled public String subtype { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public String body { get; set; }
    @AuraEnabled public String correction { get; set; }
    @AuraEnabled public String feedback { get; set; }
    @AuraEnabled public Long eventTime { get; set; }

    public class Actor {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public String role { get; set; }

        public Actor() {}

        public Actor(String role) {
            this.role = role;
        }

        public Actor(User u) {
            this.id = u.Id;
            this.name = u.Name;
            this.alias = u.Alias;
            this.role = 'user';
        }
    }

    public ThreadEventWrapper() {}

    public ThreadEventWrapper(Thread_Event__c threadEvent) {
        this.threadId = threadEvent.Thread__c;
        this.externalId = threadEvent.External_Id__c;
        this.salesforceId = threadEvent.Id;
        this.name = threadEvent.Name;
        this.actor = new Actor(threadEvent.CreatedBy);
        this.type = threadEvent.Type__c;
        this.body = threadEvent.Body__c;
        this.correction = threadEvent.Function_Correction__c;
        this.feedback = threadEvent.Feedback__c;
        this.eventTime = threadEvent.CreatedDate?.getTime();
    }

    public Thread_Event__c unwrap() {
        Thread_Event__c threadEvent = new Thread_Event__c();
        if (this.salesforceId != null) {
            threadEvent.Id = this.salesforceId;
        }
        threadEvent.Thread__c = this.threadId;
        threadEvent.External_Id__c = this.externalId;
        threadEvent.Type__c = this.type;
        threadEvent.Body__c = this.body;
        threadEvent.Function_Correction__c = this.correction;
        threadEvent.Feedback__c = this.feedback;
        return threadEvent;
    }

    public static ThreadEventWrapper[] wrap(Thread_Event__c[] threadEvents) {
        ThreadEventWrapper[] res = new List<ThreadEventWrapper>();
        if (threadEvents != null && !threadEvents.isEmpty()) {
            for (Integer i = 0; i < threadEvents.size(); i++) {
                res.add(new ThreadEventWrapper(threadEvents[i]));
            }
        }
        return res;
    }
}