import { Framework } from './base';
import { LanguageId } from '~/utils';
declare class UI5Framework extends Framework {
    id: string;
    display: string;
    detection: {
        packageJSON: string[];
    };
    languageIds: LanguageId[];
    usageMatchRegex: string[];
    refactorTemplates(keypath: string): string[];
    rewriteKeys(key: string): string;
    enabledParsers: string[];
    pathMatcher(): string;
    enableFeatures: {
        LinkedMessages: boolean;
    };
    perferredLocalePaths: string[];
    perferredKeystyle: "flat";
}
export default UI5Framework;
