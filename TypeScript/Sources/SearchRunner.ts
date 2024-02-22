import * as lunr from "lunr";
import { AnySymbol } from "./AnySymbol";
import { SearchOutput } from "./SearchOutput";

export class SearchRunner {
    index: lunr.Index;
    symbols: AnySymbol[];

    constructor(symbols: AnySymbol[]) {
        this.symbols = symbols;
        this.index = lunr(function () {
            this.ref('i');
            this.field('mwords');
            this.field('pwords');

            // disable stemming
            this.pipeline.remove(lunr.stemmer);
            this.searchPipeline.remove(lunr.stemmer);

            for (let i = 0; i < symbols.length; i++) {
                const symbol: AnySymbol = symbols[i];
                if ('module' in symbol) {
                    this.add({ i: i, mwords: symbol.keywords }, { boost: symbol.weight });
                } else {
                    this.add({ i: i, pwords: symbol.keywords }, { boost: 10 });
                }
            }
        });
    }

    search(expression: string, packagesOnly: boolean): SearchOutput | null {
        if (expression.length === 0) {
            return null;
        }

        let needles: string[] = []
        for (const needle of expression.toLowerCase().split(/[\-\s\.]/)) {
            if (needle.length > 0) {
                needles.push(needle);
            }
        }

        let results: lunr.Index.Result[];
        if (needles.length > 0) {
            results = this.index.query(function (query: lunr.Query) {
                const fields: string[] = packagesOnly ? ['pwords'] : ['mwords', 'pwords'];

                for (const needle of needles) {
                    query.term(needle, {
                        fields: fields,
                        boost: 100
                    });
                    query.term(needle, {
                        fields: fields,
                        boost: 10,
                        wildcard: lunr.Query.wildcard.TRAILING
                    });
                    query.term(needle, {
                        fields: fields,
                        boost: 5,
                        wildcard: lunr.Query.wildcard.TRAILING,
                        editDistance: 1
                    });
                    query.term(needle, {
                        fields: fields,
                        boost: 1,
                        wildcard: lunr.Query.wildcard.TRAILING,
                        editDistance: 2
                    });
                }
            });
        } else {
            results = [];
        }
        if (results.length > 0) {
            return new SearchOutput(results.slice(0, 10));
        } else {
            return null;
        }
    }
}
