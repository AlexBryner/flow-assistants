import { LightningElement, api, track } from 'lwc';

import getThread from '@salesforce/apex/ThreadController.getThread';
import createThread from '@salesforce/apex/ThreadController.createThread';
import postUserMessage from '@salesforce/apex/ThreadController.postUserMessage';
import routeThreadToAssistant from "@salesforce/apex/ThreadController.routeThreadToAssistant";
import checkThreadStatus from '@salesforce/apex/ThreadController.checkThreadStatus';
import getNewMessages from '@salesforce/apex/ThreadController.getNewMessages';

import * as threadMod from './mods/index.js';

export default class Thread extends LightningElement {

    _recordId;
    /**
     * Using getter/setters because this component may be used on an app layout or on a record page.
     * If the record id is not set by the page then it will need tobe set with the conversation begins.
     * @returns String
     */
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(val) {
        if (val && val !== this._recordId) {
            this.pullThread(val);
        }
        this._recordId = val;
    }

    /**
     * Title Expected to be set by the page
     * @type {string}
     */
    @api title = 'OpenAI Assistant Thread';

    @api assistantName = '';

    /**
     * Displays the Side Panel to view the Logs from the current session.
     * @returns {boolean}
     */
    @api 
    get displayLogs() {
        return this.isSidePanelOpen;
    }
    set displayLogs(val) {
        this.isSidePanelOpen = val;
    }

    @track status = '';
    @track threadEvents = [];
    @track logs = [];
    @track agentMessage = '';
    @track isInputDisabled = false;
    @track isSending = false;

    @track showFlow = false;
    @track flowName = '';
    @track inputVariables = [];

    isSidePanelOpen = false;
    isPollingForUpdates;
    runStatus = '';

    _threadWrapper = {
        externalId: '',
        salesforceId: '',
        assistantId: '',
        name: '',
        model: '',
        status: '',
        runId: '',
        threadEvents: [],
        toolsJson: ''
    };

    async pullThread(salesforceThreadId = ''){
        const thread = await getThread({ recordId: salesforceThreadId });
        this.setThreadWrapper(thread);
    }

    setThreadWrapper(thread) {
        this._threadWrapper = { ...this._threadWrapper, ...thread };
        this._recordId = thread.salesforceId;
        this.status = thread.status;
        this.threadEvents = threadMod.setDisplayMetaOnThreadEvents([...thread.threadEvents]);
    }

    addThreadEventWithMeta(threadEvent) {
        this.threadEvents = threadMod.setDisplayMetaOnThreadEvents([...this.threadEvents, threadEvent]);
        this.scrollToBottomAsync();
    }

    addThreadEventsWithMeta(threadEvents = []) {
        this.threadEvents = threadMod.setDisplayMetaOnThreadEvents([...this.threadEvents, ...threadEvents]);
        this.scrollToBottomAsync();
    }

    scrollToBottomAsync() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(this.scrollToBottom.bind(this), 0);
    }

    scrollToBottom() {
        const chatContainer = this.template.querySelector('.slds-chat-container');
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }

    handleInputChange(event) {
        this.agentMessage = event.target.value;
    }

    handleKeyUp(event) {
        if (event.key === 'Enter') {
            this.sendMessage();
        }
    }

    startPollingForUpdates() {
        console.log('###', 'Polling for Updates');
        this.runStatus = '';
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.isPollingForUpdates = setInterval(this.pollForUpdates.bind(this), 2000);
    }

    stopPolling() {
        window.clearInterval(this.isPollingForUpdates);
        this.isPollingForUpdates = undefined;
    }

    async pollForUpdates() {
        const res = await checkThreadStatus({ salesforceThreadId: this.recordId });
        console.groupCollapsed('###', 'Response Status:', res.status)
        console.log('###', 'Response Status:', res.status);
        console.log('###', 'Response Body:', JSON.parse(res.body));
        if (res.status === 'completed') {
            this.stopPolling();
            const newThreadEvents = await getNewMessages({ salesforceThreadId: this.recordId });
            console.log('###', 'Pulled New Events:', newThreadEvents);
            this.addThreadEventsWithMeta(newThreadEvents);
            this.enableInput();
        } else if (res.status === 'requires_action') {
            this.stopPolling();
            console.log('###', 'Pulled Function Call:', JSON.parse(res.body));
            const params = threadMod.extractParametersFromFunction(res.body);
            this.setFlowVariables(params);
            this.isSending = false;
            this.showFlow = true;
        }
        console.groupEnd();
    }

    async sendMessage(){
        this.disableInput();
        if (!this.recordId) {
            // if this is a brand new conversation, need to create the thread with OpenAI
            const threadWrapper = await createThread();
            this.setThreadWrapper(threadWrapper);
        }

        // posting the message to Salesforce and OpenAI
        await this.createUserThreadEvent(this.agentMessage);

        if (!this._threadWrapper.assistantId) {
            // if the thread hasn't already been routed to an assistant need to do this
            const assignedAssistant = await routeThreadToAssistant({ salesforceThreadId: this.recordId, assistantName: this.assistantName });
            console.log('###', 'Running Assistant:', assignedAssistant);
        }

        this.startPollingForUpdates();
    }

    disableInput() {
        this.isInputDisabled = true;
        this.isSending = true;
    }

    enableInput() {
        this.isInputDisabled = false;
        this.isSending = false;
    }

    setFlowVariables(body) {
        this.flowName = body.flowName;
        const vars = body.inputVariables.map(iv => {
            const type = iv.type[0].toUpperCase() + iv.type.substring(1).toLowerCase(); // flows choke on lower case types?
            let value;
            if (type === 'String') {
                value =  iv.value ?? ''; // flows choke on null references
            } else if (type === 'Boolean') {
                value = iv.value ?? false; // flows choke on null references
            } else if (type === 'Number') {
                value = parseInt(iv.value ?? '0', 10);
            }
            // TODO: add more variable type defaults
            return { ...iv, type, value }
        });
        console.log('###', 'Input Variables:', vars)
        this.inputVariables = [...vars];
    }

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            console.log('###', 'Flow Finished');
            console.log('###', event.detail);
            this.showFlow = false;
            this._threadWrapper.assistantId = undefined; // will need to kick back off to an assistant if going to continue
        }
    }

    async createUserThreadEvent(body = '') {
        const newThreadEvent = await postUserMessage({
            salesforceThreadId: this.recordId,
            userMessage: body
        });
        this.addThreadEventWithMeta(newThreadEvent);
        this.agentMessage = '';
    }
}