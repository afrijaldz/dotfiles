/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
exports.runSafe = exports.formatError = void 0;
function formatError(message, err) {
    if (err instanceof Error) {
        var error = err;
        return "".concat(message, ": ").concat(error.message, "\n").concat(error.stack);
    }
    else if (typeof err === 'string') {
        return "".concat(message, ": ").concat(err);
    }
    else if (err) {
        return "".concat(message, ": ").concat(err.toString());
    }
    return message;
}
exports.formatError = formatError;
function runSafe(func, errorVal, errorMessage) {
    try {
        var t = func();
        if (t instanceof Promise) {
            return t.then(void 0, function (e) {
                console.error(formatError(errorMessage, e));
                return errorVal;
            });
        }
        return t;
    }
    catch (e) {
        console.error(formatError(errorMessage, e));
        return errorVal;
    }
}
exports.runSafe = runSafe;
