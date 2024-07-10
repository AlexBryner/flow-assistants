public with sharing class ThreadWrapper {

    @AuraEnabled public String externalId { get; set; }
    @AuraEnabled public String salesforceId { get; set; }
    @AuraEnabled public String assistantId { get; set; }
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public String model { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public String runId { get; set; }
    @AuraEnabled public Long runExpiresAt { get; set; }
    @AuraEnabled public Long endedAt { get; set; }
    @AuraEnabled public ThreadEventWrapper[] threadEvents { get; set; }
    @AuraEnabled public String toolsJson { get; set; }

    public ThreadWrapper(Thread__c thread) {
        System.debug('Wrapping Thread:' + JSON.serialize(thread));
        this.salesforceId = thread.Id;
        this.name = thread.Name;
        this.externalId = thread.External_Id__c;
        this.model = thread.Model__c;
        this.status = thread.Status__c;
        this.runId = thread.Run_Id__c;
        this.endedAt = thread.Ended_At__c?.getTime();
        this.threadEvents = new List<ThreadEventWrapper>();

        if (thread.Events__r != null && !thread.Events__r.isEmpty()) {
            for (Integer i = 0; i < thread.Events__r.size(); i++) {
                threadEvents.add(new ThreadEventWrapper(thread.Events__r[i]));
            }
        }
    }

    public ThreadWrapper(OpenAiThread thread) {

    }

    public ThreadWrapper(OpenAiThreadRun threadRun) {
        this.externalId = threadRun.thread_id;
        this.runId = threadRun.id;
        this.assistantId = threadRun.assistant_id;
        this.status = threadRun.status;
        this.runExpiresAt = threadRun.expires_at;
        this.model = threadRun.model;
        this.toolsJson = JSON.serialize(threadRun.tools);
    }
}