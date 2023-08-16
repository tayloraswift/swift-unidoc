import * as lunr from "lunr";
import { Symbol } from "./Symbol";
import { SearchOutput } from "./SearchOutput";

export class SearchIndex {
    index:lunr.Index;
    symbols:Symbol[];

    constructor(symbols:Symbol[]) {
        this.symbols = symbols;
        this.index = lunr(function() {
            this.ref('i');
            this.field('text');

            // disable stemming
            this.pipeline.remove(lunr.stemmer);
            this.searchPipeline.remove(lunr.stemmer);

            for (let i = 0; i < symbols.length; i++) {
                this.add({i: i, text: symbols[i].signature});
            }
        });
    }

    search(needle:string):SearchOutput | undefined {
        let results:lunr.Index.Result[];
        if (needle.length > 0) {
            results = this.index.query(function(query:lunr.Query) {
                query.term(needle, { boost: 100});
                query.term(needle, { boost:  10,
                    wildcard: lunr.Query.wildcard.TRAILING
                });
                query.term(needle, { boost:   5,
                    wildcard: lunr.Query.wildcard.TRAILING,
                    editDistance: 1
                });
                query.term(needle, { boost:   1,
                    wildcard: lunr.Query.wildcard.TRAILING,
                    editDistance: 2
                });
            });
        } else {
            results = [];
        }
        if (results.length > 0) {
            return new SearchOutput(results.slice(0, 10));
        } else {
            return undefined
        }
    }
}
