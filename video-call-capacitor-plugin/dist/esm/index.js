import { registerPlugin } from '@capacitor/core';
const StreamVideoCallCapacitor = registerPlugin('StreamVideoCallCapacitor', {
    web: () => import('./web').then((m) => new m.StreamVideoCallCapacitorWeb()),
});
export * from './definitions';
export { StreamVideoCallCapacitor };
//# sourceMappingURL=index.js.map