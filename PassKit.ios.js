/**
 * @flow
 */
"use strict";

import { NativeModules, NativeEventEmitter } from "react-native";
import type EmitterSubscription from "EmitterSubscription";

const nativeModule = NativeModules.RNPassKit;
const nativeEventEmitter = new NativeEventEmitter(nativeModule);

export default {
    ...nativeModule,

    addPass: (base64Encoded: string, fileProvider?: string): Promise<void> => {
        return nativeModule.addPass(base64Encoded);
    },

    addPasses: (arrayOfBase64Encoded: Array, fileProvider?: string): Promise<void> => {
        return nativeModule.addPasses(arrayOfBase64Encoded);
    },

    presentAddPassesViewController: (base64Encoded: string): Promise<void> => {
        // eslint-disable-next-line no-console
        console.warn("PassKit.presentAddPassesViewController is deprecated. Use PassKit.addPass instead.");
        return nativeModule.addPass(base64Encoded);
    },

    addEventListener: (eventType: string, listener: Function, context: ?Object): ?EmitterSubscription => nativeEventEmitter.addListener(eventType, listener, context),

    removeEventListener: (eventType: string, listener: Function): void => {
        nativeEventEmitter.removeListener(eventType, listener);
    },
};
