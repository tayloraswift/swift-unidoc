import * as lunr from "lunr"
import { SearchIndex } from "./SearchIndex";
import { NounMapCulture } from "./NounMapCulture";
import { SearchRunner } from "./SearchRunner";
import { SearchOutput } from "./SearchOutput";
import { SearchVolume } from "./SearchVolume";
import { AnySymbol } from "./AnySymbol";

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

        //  Get the list of all packages in the index.
        let requests: Promise<SearchIndex | string[]>[] = [
            fetch('/lunr/packages.json').then(
                async function (response: Response): Promise<string[]> {
                    return response.json();
                }),
        ];
        //  Get the search indexes for the dependencies of the current volume.
        for (const volume of volumes) {
            const uri: string = '/lunr/' + volume.id;

            requests.push(fetch(uri).then(
                async function (response: Response): Promise<SearchIndex> {
                    return response.json().then(
                        function (cultures: NounMapCulture[]): SearchIndex {
                            return { cultures: cultures, trunk: volume.trunk };
                        });
                }));
        }
        this.runner = await Promise.all(requests)
            .then(function (indexes: (SearchIndex | string[])[]): SearchRunner {
                let symbols: AnySymbol[] = [];
                let exclude: Set<string> = new Set<string>();

                for (const volume of volumes) {
                    const dependency: string = volume.id.split(':')[0];

                    exclude.add(dependency);

                    symbols.push({
                        dependency: true,
                        keywords: dependency.split(/\-/),
                        name: dependency,
                        uri: volume.trunk,
                    });
                }

                for (const index of indexes) {
                    if (index instanceof Array) {
                        for (const id of index) {
                            if (exclude.has(id)) {
                                continue;
                            }
                            symbols.push({
                                dependency: false,
                                keywords: id.split(/\-/),
                                name: id,
                                uri: '/tags/' + id
                            });
                        }
                    } else {
                        for (const culture of index.cultures) {
                            const module: string = culture.c;
                            for (const noun of culture.n) {
                                var uri: string = index.trunk + '/';
                                uri += noun.s
                                    .replace('\t', '.')
                                    .replaceAll(' ', '/')
                                    .toLowerCase();

                                const stem: string[] = noun.s.split(/\s+/);

                                symbols.push({
                                    module: module,
                                    keywords: stem,
                                    display: stem.slice(1).join('.'),
                                    uri: uri
                                });
                            }
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
            const symbol: AnySymbol = this.runner.symbols[parseInt(result.ref)];

            const item: HTMLElement = document.createElement("li");
            const anchor: HTMLElement = document.createElement("a");
            const display: HTMLElement = document.createElement("span");
            const category: HTMLElement = document.createElement("span");

            if ('dependency' in symbol) {
                if (symbol.dependency) {
                    category.appendChild(document.createTextNode('Package Dependency'));
                    item.classList.add('package', 'dependency');
                } else {
                    category.appendChild(document.createTextNode('Package'));
                    item.classList.add('package');
                }

                display.appendChild(document.createTextNode(symbol.name));
            } else {
                category.appendChild(document.createTextNode(symbol.module));
                category.classList.add('module');

                display.appendChild(document.createTextNode(symbol.display));
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
