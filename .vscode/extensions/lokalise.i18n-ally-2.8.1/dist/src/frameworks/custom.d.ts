import { Framework } from './base';
import { LanguageId } from '~/utils';
declare class CustomFramework extends Framework {
    id: string;
    display: string;
    private watchingFor;
    private watcher;
    private data;
    detection: {
        none: (_: string[], root: string) => boolean;
    };
    load(root: string): boolean;
    get languageIds(): LanguageId[];
    get usageMatchRegex(): string[];
    get monopoly(): boolean;
    set monopoly(_: boolean);
    refactorTemplates(keypath: string): string[];
    startWatch(root?: string): void;
}
export default CustomFramework;
