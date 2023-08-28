import * as lunr from "lunr"

export class SearchOutput {
    index: number;
    choices: lunr.Index.Result[];

    constructor(choices: lunr.Index.Result[]) {
        this.index = 0;
        this.choices = choices;
    }

    highlight(output: HTMLElement) {
        const item: Element | null = output.children.item(this.index);
        if (item instanceof HTMLElement) {
            item.classList.add('selected');
        }
    }
    rehighlight(output: HTMLElement, index: number) {
        if (index == this.index) {
            return;
        }

        const item: Element | null = output.children.item(this.index);
        if (item instanceof HTMLElement) {
            item.classList.remove('selected');
            if (item.classList.length == 0) {
                item.removeAttribute('class');
            }

            this.index = index;
            this.highlight(output);
        }
    }
}
