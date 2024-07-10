public with sharing class ThreadController {

    @AuraEnabled
    public static ThreadWrapper createThread() {
        try {
            return new ThreadService().createThread();
        } catch (Exception err) {
            throw new ThreadException('Error Creating Thread: ' + err);
        }
    }

    @AuraEnabled
    public static ThreadWrapper getThread(String recordId) {
        try {
            System.debug('Pulling Thread for: ' + recordId);
            return new ThreadService().getThread(
                    String.escapeSingleQuotes(recordId)
            );
        } catch (Exception err) {
            throw new ThreadException('Error Pulling Thread: ' + err);
        }
    }

    @AuraEnabled
    public static ThreadWrapper routeThreadToAssistant(String salesforceThreadId, String assistantName) {
        // try {
            System.debug('Routing Thread ' + salesforceThreadId + ' to ' + assistantName);
            return new ThreadService().routeThreadToAssistant(
                    String.escapeSingleQuotes(salesforceThreadId),
                    String.escapeSingleQuotes(assistantName)
            );
        // } catch (Exception err) {
        //     throw new ThreadException('Error Posting Message: ' + err);
        // }
    }

    @AuraEnabled
    public static ThreadEventWrapper postUserMessage(String salesforceThreadId, String userMessage) {
        try {
            System.debug('Posting To Thread for: ' + salesforceThreadId);
            return new ThreadService().postUserMessage(
                    String.escapeSingleQuotes(salesforceThreadId),
                    String.escapeSingleQuotes(userMessage)
            );
        } catch (Exception err) {
            throw new ThreadException('Error Posting Message: ' + err);
        }
    }

    @AuraEnabled
    public static ThreadEventWrapper postUserMessageWithFiles(String salesforceThreadId, String userMessage, String[] fileIds) {
        try {
            System.debug('Posting To Thread for: ' + salesforceThreadId);
            return new ThreadService().postUserMessageWithFiles(
                    String.escapeSingleQuotes(salesforceThreadId),
                    String.escapeSingleQuotes(userMessage),
                    fileIds
            );
        } catch (Exception err) {
            throw new ThreadException('Error Posting Message: ' + err);
        }
    }

    @AuraEnabled
    public static ThreadEventWrapper checkThreadStatus(String salesforceThreadId) {
        try {
            return new ThreadService().checkThreadStatus(
                    String.escapeSingleQuotes(salesforceThreadId)
            );
        } catch (Exception err) {
            throw new ThreadException('Error Posting Message: ' + err);
        }
    }

    @AuraEnabled
    public static ThreadEventWrapper[] getNewMessages(String salesforceThreadId) {
        try {
            return new ThreadService().getNewMessages(
                    String.escapeSingleQuotes(salesforceThreadId)
            );
        } catch (Exception err) {
            throw new ThreadException('Error Posting Message: ' + err);
        }
    }

    public class ThreadException extends Exception {}
}