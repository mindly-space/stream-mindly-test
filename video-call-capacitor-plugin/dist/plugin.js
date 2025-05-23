var capacitorStreamVideoCallCapacitor = (function (exports, core) {
    'use strict';

    const StreamVideoCallCapacitor = core.registerPlugin('StreamVideoCallCapacitor', {
        web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.StreamVideoCallCapacitorWeb()),
    });

    class StreamVideoCallCapacitorWeb extends core.WebPlugin {
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

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        StreamVideoCallCapacitorWeb: StreamVideoCallCapacitorWeb
    });

    exports.StreamVideoCallCapacitor = StreamVideoCallCapacitor;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
