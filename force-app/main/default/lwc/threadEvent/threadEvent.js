import { LightningElement, api, track } from 'lwc';
import * as threadEventMods from './mods/index.js';
import inboundTemplate from "./templates/inbound.html";
import outboundTemplate from "./templates/outbound.html";
import startedTemplate from './templates/started.html';
import stoppedTemplate from './templates/stopped.html';
import defaultTemplate from './templates/default.html';

export default class ThreadEvent extends LightningElement {

    _threadEvent = {};

    @track type = 'inbound';
    @track body = '';
    @track actor = {};
    @track eventTime;
    @track displayMeta = false;

    @api
    get threadEvent() {
        return this._threadEvent;
    }
    set threadEvent(val) {
        this._threadEvent = val;
        this.type = val.type;
        this.body = threadEventMods.markdownToHtml(val.body);
        this.actor = val.actor;
        this.eventTime = val.eventTime;
        this.displayMeta = val.displayMeta;
    }

    render() {
        switch (this.type.toLowerCase()) {
            case 'inbound':
                return inboundTemplate;
            case 'outbound':
                return outboundTemplate;
            case 'started':
                return startedTemplate;
            case 'stopped':
                return stoppedTemplate;
            default:
                return defaultTemplate;
        }
    }

    get messageBodyClass() {
        return `slds-chat-message__body ${this.displayMeta ? '' : 'slds-chat-message__body slds-chat-message_faux-avatar'}`;
    }
}