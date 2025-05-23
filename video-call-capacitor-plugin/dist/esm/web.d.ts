import type { PluginListenerHandle } from '@capacitor/core';
import { WebPlugin } from '@capacitor/core';
import type { StreamVideoCallCapacitorPlugin, StreamVideoInitOptions, StreamVideoCallOptions, StreamVideoCallEventPayload, StreamVideoCallEvents } from './definitions';
export declare class StreamVideoCallCapacitorWeb extends WebPlugin implements StreamVideoCallCapacitorPlugin {
    initializeVideoCall(options: StreamVideoInitOptions): Promise<void>;
    joinCall(options: StreamVideoCallOptions): Promise<void>;
    addListener<EventType extends StreamVideoCallEvents>(event: EventType, listenerFunc: (event: StreamVideoCallEventPayload[EventType]) => void): Promise<PluginListenerHandle>;
    removeAllListeners(): Promise<void>;
}
