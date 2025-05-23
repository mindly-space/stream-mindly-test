import { WebPlugin } from '@capacitor/core';
export class StreamVideoCallCapacitorWeb extends WebPlugin {
    async initializeVideoCall(options) {
        console.log('[StreamVideoCall]: initialize web video call', options);
    }
    async joinCall(options) {
        console.log('[StreamVideoCall]: joinCall web video call', options);
    }
    addListener(event, listenerFunc) {
        console.log(`[StreamVideoCall]: Added listener for event ${event}`);
        return super.addListener(event, listenerFunc);
    }
    removeAllListeners() {
        console.log(`[StreamVideoCall]: Removed listener for event ${event}`);
        return super.removeAllListeners();
    }
}
//# sourceMappingURL=web.js.map