export interface StreamVideoCallCapacitorPlugin {
    initializeVideoCall(options: StreamVideoInitOptions): Promise<void>;
    joinCall(options: StreamVideoCallOptions): Promise<void>;
    addListener<EventType extends StreamVideoCallEvents>(event: EventType, listenerFunc: (event: StreamVideoCallEventPayload[EventType]) => void): Promise<PluginListenerHandle>;
    removeAllListeners(): Promise<void>;
}
export interface UserInfo {
    id: string;
    name: string;
    imageURL?: string;
}
export interface StreamVideoInitOptions {
    apiKey: string;
    token: string;
    preferredExtension: string;
    user: UserInfo;
}
export interface StreamVideoCallOptions {
    callId: string;
}
export declare type StreamVideoCallEvents = 'callJoined' | 'callEnded';
export interface StreamVideoCallEventPayload {
    callJoined: {
        callId: string;
        userId: string;
    };
    callEnded: {
        callId: string;
    };
}
export interface PluginListenerHandle {
    remove: () => Promise<void>;
}
