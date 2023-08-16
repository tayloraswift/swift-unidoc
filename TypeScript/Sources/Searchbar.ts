import * as lunr from "lunr"
import { NounMap } from "./NounMap";
import { NounMapCulture } from "./NounMapCulture";
import { SearchIndex } from "./SearchIndex";
import { SearchOutput } from "./SearchOutput";
import { Symbol } from "./Symbol";

declare const nouns:string[];

export class Searchbar {
    list:HTMLElement;

    index?:SearchIndex;
    loading:boolean;

    pending?:Event;
    output?:SearchOutput;

    constructor(output:{list:HTMLElement}) {
        this.loading = false;
        this.list = output.list;
    }

    async focus() {
        this.list.classList.remove('occluded');
        await this.reinitialize();
    }

    async reinitialize() {
        console.log("Reinitializing search index");

        if (this.loading || this.index !== undefined) {
            return;
        }
        this.loading = true;

        let requests:Promise<NounMap>[] = [];
        for (const uri of nouns) {
            requests.push(fetch(uri).then(async function(response:Response):Promise<NounMap> {
                return response.json().then(function(cultures:NounMapCulture[]):NounMap {
                    return { id: uri, cultures: cultures };
                });
            }));
        }
        this.index = await Promise.all(requests)
            .then(function(zones:NounMap[]):SearchIndex {
                let symbols:Symbol[] = [];
                const here:string[] = window.location.pathname.split('/');
                for (const zone of zones) {
                    for (const culture of zone.cultures) {
                        const module:string = culture.c;
                        for (const noun of culture.n) {
                            var uri:string = '/' + here[1] + '/' + here[2] + '/';
                                uri += noun.s
                                    .replace('\t', '.')
                                    .replaceAll(' ', '/')
                                    .toLowerCase();
                            symbols.push({
                                module: module,
                                signature: noun.s.split(/\s+/),
                                display: noun.s,
                                uri: uri
                            });
                        }
                    }
                }
                return new SearchIndex(symbols);
            })
            .catch(function(error:Error):undefined {
                console.error('error:', error);
                return undefined;
            });
        this.loading = false;
        if (this.pending !== undefined) {
            this.suggest(this.pending);
        }
    }

    suggest(event:Event) {
        if (this.index === undefined) {
            this.pending = event;
            return;
        } else {
            this.pending = undefined;
        }
        // *not* current target, as that will not work for pending events
        const input:HTMLInputElement = event.target as HTMLInputElement;
        this.output = this.index.search(input.value.toLowerCase());
        if (this.output === undefined) {
            this.list.replaceChildren();
            return;
        }

        let items:HTMLElement[] = [];
        for (const result of this.output.choices) {
            const symbol:Symbol = this.index.symbols[parseInt(result.ref)];

            const item:HTMLElement = document.createElement("li");
            const anchor:HTMLElement = document.createElement("a");
            const display:HTMLElement = document.createElement("span");
            const module:HTMLElement = document.createElement("span");

            display.appendChild(document.createTextNode(symbol.display));
            module.appendChild(document.createTextNode(symbol.module));

            anchor.appendChild(display);
            anchor.appendChild(module);
            anchor.setAttribute('href', symbol.uri);

            item.appendChild(anchor);
            items.push(item);
        }
        this.list.replaceChildren(...items);
        this.output.highlight(this.list);
    }

    navigate(event:KeyboardEvent) {
        if (this.output === undefined) {
            return;
        }
        switch (event.key) {
            case 'ArrowUp': {
                if (this.output.index > 0) {
                    this.output.rehighlight(this.list, this.output.index - 1);
                    event.preventDefault();
                }
                break;
            }
            case 'ArrowDown': {
                if (this.output.index < this.output.choices.length - 1) {
                    this.output.rehighlight(this.list, this.output.index + 1);
                    event.preventDefault();
                }
                break;
            }
            default:
                break;
        }
    }

    follow(event:Event) {
        event.preventDefault();
        if (this.output === undefined || this.index === undefined) {
            return;
        }
        const choice:lunr.Index.Result = this.output.choices[this.output.index];
        window.location.assign(this.index.symbols[parseInt(choice.ref)].uri);
    }
}
