public with sharing class ThreadService {

    public ThreadWrapper createThread() {
        OpenAiThread serviceThread = new OpenAi().createThread();
        Thread__c t = new Thread__c(External_Id__c = serviceThread.id);
        insert t;

        return getThread(t.Id);
    }

    public ThreadWrapper routeThreadToAssistant(String threadId, String assistantName) {
        String threadExternalId = ThreadSelector.getThread(threadId)?.External_Id__c;
        String assistantExternalId = [SELECT External_Id__c FROM OpenAI_Assistant__mdt WHERE DeveloperName = :assistantName]?.External_Id__c;

        // calling open ai to set an assistant to the thread
        ThreadWrapper res = new ThreadWrapper(new OpenAi().setAssistant(threadExternalId, assistantExternalId));

        // saving updates from the run response
        update new Thread__c(
                Id = threadId,
                Assistant_Name__c = assistantName,
                Run_Id__c = res.runId,
                Model__c = res.model
        );

        return res;
    }

    public ThreadWrapper getThread(Id threadId) {
        Thread__c thread = ThreadSelector.getThread(threadId);
        return new ThreadWrapper(thread);
    }

    public ThreadEventWrapper postUserMessage(String salesforceThreadId, String userMessage) {
        Thread__c sfThread = [SELECT Id, External_Id__c FROM Thread__c WHERE Id = :salesforceThreadId];
        if (sfThread == null) {
            throw new ThreadServiceException('Unable To Find Salesforce Thread For: ' + salesforceThreadId);
        }

        String externalId = sfThread.External_Id__c;
        if (externalId == null) {
            throw new ThreadServiceException('Missing External Thread Id For: ' + salesforceThreadId);
        }

        OpenAiThreadMessage openAiMessage = new OpenAi().postMessage(externalId, userMessage);

        // saving the message to Salesforce
        Thread_Event__c te = new Thread_Event__c(
                Thread__c = salesforceThreadId,
                External_Id__c = openAiMessage.id,
                Type__c = 'Outbound',
                Body__c = userMessage
        );
        insert te;

        return new ThreadEventWrapper(ThreadSelector.getThreadEvent(te.Id));
    }

    public ThreadEventWrapper postUserMessageWithFiles(String salesforceThreadId, String userMessage, String[] fileIds) {
        Thread__c sfThread = [SELECT Id, External_Id__c FROM Thread__c WHERE Id = :salesforceThreadId];
        if (sfThread == null) {
            throw new ThreadServiceException('Unable To Find Salesforce Thread For: ' + salesforceThreadId);
        }

        String externalId = sfThread.External_Id__c;
        if (externalId == null) {
            throw new ThreadServiceException('Missing External Thread Id For: ' + salesforceThreadId);
        }

        OpenAiThreadMessage openAiMessage = new OpenAi().postMessage(externalId, userMessage, fileIds);

        // saving the message to Salesforce
        Thread_Event__c te = new Thread_Event__c(
                Thread__c = salesforceThreadId,
                External_Id__c = openAiMessage.id,
                Type__c = 'Outbound',
                Body__c = userMessage
        );
        insert te;

        return new ThreadEventWrapper(ThreadSelector.getThreadEvent(te.Id));
    }

    public ThreadEventWrapper checkThreadStatus(String salesforceThreadId) {
        Thread__c sfThread = [SELECT Id, External_Id__c, Run_Id__c FROM Thread__c WHERE Id = :salesforceThreadId];
        String threadRunResponse = new OpenAi().checkRunStatus(sfThread.External_Id__c, sfThread.Run_Id__c);
        ThreadEventWrapper threadEvent = new ThreadEventWrapper();
        threadEvent.salesforceId = salesforceThreadId;
        threadEvent.type = 'Meta';
        threadEvent.subtype = 'status_update';
        threadEvent.status = (String) ((Map<String, Object>) JSON.deserializeUntyped(threadRunResponse)).get('status');
        threadEvent.body = threadRunResponse;
        return threadEvent;
    }

    public ThreadEventWrapper[] getNewMessages(String salesforceThreadId) {
        Thread__c sfThread = [SELECT Id, External_Id__c, Run_Id__c FROM Thread__c WHERE Id = :salesforceThreadId];
        String messageResponse = new OpenAi().getMessages(sfThread.External_Id__c);
        System.debug('MessageResponse:' + messageResponse);
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(messageResponse);
        Object[] messages = (Object[]) root.get('data');
        Map<String, ThreadEventWrapper> newEventsByExternalId = new Map<String, ThreadEventWrapper>();

        for (Integer i = 0; i < messages.size(); i++) {
            Map<String, Object> message = (Map<String, Object>) messages[i];
            System.debug('Message: ' + JSON.serialize(message));
            String messageType = (String) message.get('object');
            String actorType = (String) message.get('role');

            ThreadEventWrapper eventWrapper = new ThreadEventWrapper();
            eventWrapper.threadId = salesforceThreadId;
            eventWrapper.actor = new ThreadEventWrapper.Actor(actorType);
            eventWrapper.externalId = (String) message.get('id');
            eventWrapper.eventTime = (Long) message.get('created_at');

            Object[] contents = (Object[]) message.get('content');
            eventWrapper.body = '';
            for (Integer c = 0; c < contents.size(); c++) {
                if (c > 0) {
                    eventWrapper.body += '\n\n';
                }
                Map<String, Object> contentMap = (Map<String, Object>) contents[c];
                Map<String, Object> contentText = (Map<String, Object>) contentMap.get('text');
                if (contentText != null) {
                    eventWrapper.body += (String) contentText.get('value');
                }
            }

            if (messageType == 'thread.message') {
                if (actorType == 'user') {
                    eventWrapper.type = 'Outbound';
                } else {
                    eventWrapper.type = 'Inbound';
                }
            } else {
                eventWrapper.type = 'Meta';
            }
            newEventsByExternalId.put(eventWrapper.externalId, eventWrapper);
        }

        Thread_Event__c[] currentEvents = [SELECT Id, External_Id__c FROM Thread_Event__c WHERE External_Id__c IN :newEventsByExternalId.keySet()];
        System.debug('CurrentEvents:' + JSON.serialize(currentEvents));
        if (currentEvents != null && !currentEvents.isEmpty()) {
            for (Integer i = 0; i < currentEvents.size(); i++) {
                ThreadEventWrapper removedEvent = newEventsByExternalId.remove(currentEvents[i].External_Id__c);
                System.debug('Removed Event: ' + JSON.serialize(removedEvent));
            }
        }

        ThreadEventWrapper[] createWrappers = newEventsByExternalId.values();
        System.debug('Need To Create Wrappers:' + JSON.serialize(createWrappers));
        if (createWrappers.isEmpty()) {
            return newEventsByExternalId.values();
        }

        Id[] newThreadEventIds = new List<Id>();
        for (Integer i = 0; i < createWrappers.size(); i++) {
            // splitting out the events that need to be created via the api and the rest that will be committed
            // everything else should have already just been created...
            // TODO: should probably change this to wait to create the message until it is received here...
            if (createWrappers[i].actor.role == 'assistant') {
                newThreadEventIds.add(ThreadEventService.createAsOpenAi(createWrappers[i].unwrap()));
            }
        }
        return ThreadEventWrapper.wrap(ThreadSelector.getThreadEvents(newThreadEventIds));
    }


    public class ThreadServiceException extends Exception {}
}