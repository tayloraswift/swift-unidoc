import * as lunr from "lunr"
import { SearchIndex } from "./SearchIndex";
import { NounMapCulture } from "./NounMapCulture";
import { SearchRunner } from "./SearchRunner";
import { SearchOutput } from "./SearchOutput";
import { SearchVolume } from "./SearchVolume";
import { Symbol } from "./Symbol";

declare const volumes: SearchVolume[];

export class Searchbar {
    list: HTMLElement;

    runner?: SearchRunner;
    loading: boolean;

    pending?: Event;
    output?: SearchOutput;

    constructor(output: { list: HTMLElement }) {
        this.loading = false;
        this.list = output.list;
    }

    async focus() {
        this.list.classList.remove('occluded');
        await this.reinitialize();
    }

    async reinitialize() {
        console.log("Reinitializing search index");

        if (this.loading || this.runner !== undefined) {
            return;
        }
        this.loading = true;

        let requests: Promise<SearchIndex>[] = [
            fetch('/lunr/packages.json').then(
                async function (response: Response): Promise<SearchIndex> {
                    return response.json().then(function (packages: string[]): SearchIndex {
                        return { packages: packages, cultures: [] };
                    });
                }),
        ];
        for (const volume of volumes) {
            const uri: string = '/lunr/' + volume.id;

            requests.push(fetch(uri).then(
                async function (response: Response): Promise<SearchIndex> {
                    return response.json().then(
                        function (cultures: NounMapCulture[]): SearchIndex {
                            return { packages: [], cultures: cultures, trunk: volume.trunk };
                        });
                }));
        }
        this.runner = await Promise.all(requests)
            .then(function (indexes: SearchIndex[]): SearchRunner {
                let symbols: Symbol[] = [];
                for (const index of indexes) {
                    for (const id of index.packages) {
                        symbols.push({
                            module: null,
                            signature: id.split(/\-/),
                            display: id,
                            uri: '/docs/' + id
                        });
                    }
                    for (const culture of index.cultures) {
                        const module: string = culture.c;
                        for (const noun of culture.n) {
                            var uri: string = index.trunk + '/';
                            uri += noun.s
                                .replace('\t', '.')
                                .replaceAll(' ', '/')
                                .toLowerCase();

                            const signature: string[] = noun.s.split(/\s+/);

                            symbols.push({
                                module: module,
                                signature: signature,
                                display: signature.slice(1).join('.'),
                                uri: uri
                            });
                        }
                    }
                }
                return new SearchRunner(symbols);
            })
            .catch(function (error: Error): undefined {
                console.error('error:', error);
                return undefined;
            });
        this.loading = false;
        if (this.pending !== undefined) {
            this.suggest(this.pending);
        }
    }

    suggest(event: Event) {
        if (this.runner === undefined) {
            this.pending = event;
            return;
        } else {
            this.pending = undefined;
        }
        // *not* current target, as that will not work for pending events
        const input: HTMLInputElement = event.target as HTMLInputElement;
        this.output = this.runner.search(input.value.toLowerCase());
        if (this.output === undefined) {
            this.list.replaceChildren();
            return;
        }

        let items: HTMLElement[] = [];
        for (const result of this.output.choices) {
            const symbol: Symbol = this.runner.symbols[parseInt(result.ref)];

            const item: HTMLElement = document.createElement("li");
            const anchor: HTMLElement = document.createElement("a");
            const display: HTMLElement = document.createElement("span");
            const category: HTMLElement = document.createElement("span");

            display.appendChild(document.createTextNode(symbol.display));

            if (symbol.module !== null) {
                category.appendChild(document.createTextNode(symbol.module));
                category.classList.add('module');
            }
            else {
                category.appendChild(document.createTextNode('(package)'));
            }

            anchor.appendChild(display);
            anchor.appendChild(category);
            anchor.setAttribute('href', symbol.uri);

            item.appendChild(anchor);
            items.push(item);
        }
        this.list.replaceChildren(...items);
        this.output.highlight(this.list);
    }

    navigate(event: KeyboardEvent) {
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

    follow(event: Event) {
        event.preventDefault();
        if (this.output === undefined || this.runner === undefined) {
            return;
        }
        const choice: lunr.Index.Result = this.output.choices[this.output.index];
        window.location.assign(this.runner.symbols[parseInt(choice.ref)].uri);
    }
}
