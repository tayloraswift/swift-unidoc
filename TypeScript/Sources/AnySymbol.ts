export type ModularSymbol = {
    module: string;
    keywords: string[];
    display: string;
    uri: string;
}

export type PackageSymbol = {
    dependency: boolean;
    keywords: string[];
    name: string;
    uri: string;
}

export type AnySymbol = ModularSymbol | PackageSymbol;
