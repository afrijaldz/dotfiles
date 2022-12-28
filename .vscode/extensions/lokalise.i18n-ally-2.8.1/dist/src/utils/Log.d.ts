import { OutputChannel } from 'vscode';
export declare class Log {
    private static _channel;
    static get outputChannel(): OutputChannel;
    static raw(...values: any[]): void;
    static info(message: string, intend?: number): void;
    static warn(message: string, prompt?: boolean, intend?: number): void;
    static error(err?: Error | string | any, prompt?: boolean, intend?: number): Promise<void>;
    static show(): void;
    static divider(): void;
}
