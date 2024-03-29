import { Searchbar } from './Searchbar';

function hex(value: number): string {
    return value.toString(16).padStart(2, "0")
}

function nonce(): string {
    const uint64: Uint8Array = new Uint8Array(8);
    return Array.from(window.crypto.getRandomValues(uint64), hex).join('')
}

const search: HTMLElement | null = document.getElementById('search');
const login: HTMLElement | null = document.getElementById('login');

if (search !== null) {
    const input: HTMLElement | null = document.getElementById('search-input');
    const list: HTMLElement | null = document.getElementById('search-results');
    const mode: HTMLElement | null = document.getElementById('search-packages-only');

    if (input !== null && list !== null) {
        const searchbar: Searchbar = new Searchbar({
            input: input as HTMLInputElement,
            mode: mode as HTMLInputElement | null,
            list: list
        });

        //  Get the existing placeholder text.
        const placeholder: string = input.getAttribute('placeholder') || '';

        input.addEventListener('focus', (event: Event) => searchbar.reinitialize());

        //  We don’t want to suggest a keyboard shortcut if the user focused the input
        //  via touch, or if they were already using the keyboard shortcut.
        input.addEventListener('mousedown', function (event: Event) {
             input.setAttribute('placeholder', 'search shortcut: /');
        });

        input.addEventListener('blur', function (event: Event) {
             input.setAttribute('placeholder', placeholder);
        });

        input.addEventListener('keydown', (event: KeyboardEvent) => searchbar.navigate(event));
        input.addEventListener('input', (event: Event) => searchbar.suggest());
        mode?.addEventListener('click', (event: Event) => searchbar.suggest());

        document.addEventListener('keydown', function (event: KeyboardEvent) {
            switch (event.key) {
                case 'Escape': {
                    if (document.activeElement === input) {
                        input.blur();
                    }
                    break;
                }
                case '/': {
                    if (document.activeElement !== input) {
                        input.focus();
                        event.preventDefault();
                    }
                    break;
                }
                case ',': {
                    if (searchbar.mode !== null) {
                        searchbar.mode.checked = !searchbar.mode.checked;
                        searchbar.suggest();
                        input.focus();
                        event.preventDefault();
                    }
                    break;
                }
            }
        });

        search.addEventListener('submit', (event: Event) => searchbar.follow(event));
    }
}

if (login !== null) {

    const input: HTMLElement = document.createElement('input');
    const state: string = nonce();

    input.setAttribute('type', 'hidden');
    input.setAttribute('name', 'state');
    input.setAttribute('value', state);

    login.appendChild(input);

    document.cookie = 'login_state=' + state + '; Path=/ ; SameSite=Lax ; Secure';
}

document.querySelectorAll('form.sort-controls').forEach((
        form: Element,
        key: number,
        all: NodeListOf<Element>
    ) => {

    //  Find an `ol` element that is a sibling of the form.
    const list: HTMLOListElement | null = form.nextElementSibling as HTMLOListElement;

    if (list === null) {
        return;
    }

    //  Look for available sort options, which are radio-type `input` elements with a `value`
    //  attribute.
    form.querySelectorAll('input[type="radio"][value]').forEach((
            radio: Element,
            key: number,
            all: NodeListOf<Element>
        ) => {

        //  Compute the name of the `data-` attribute for each sort option, and the sort
        //  predicate to use.
        const dataAttribute: string = 'data-' + radio.getAttribute('value');
        const sortPredicate: string | null = radio.getAttribute('data-predicate');

        //  Add a callback to the `click` event of each sort option that reorders the list
        //  elements according to the value of the `data-` attribute.
        //
        //  In Firefox at least, the `click` event will fire even if the radio button is
        //  selected via the keyboard.
        radio.addEventListener('click', (event: Event) => {
            const elements: NodeListOf<Element> = list.querySelectorAll('li');
            const sorted: Array<Element> = Array.from(elements).sort((
                    a: Element,
                    b: Element
                ) => {
                const aKey: string | null = a.getAttribute(dataAttribute);
                const bKey: string | null = b.getAttribute(dataAttribute);

                if (aKey === null || bKey === null) {
                    return 0;
                }

                if (sortPredicate === null) {
                    //  Use string comparison.
                    return aKey.localeCompare(bKey);
                } else if (sortPredicate === 'number-asc') {
                    //  Use numeric comparison.
                    return parseInt(aKey) - parseInt(bKey);
                } else if (sortPredicate === 'number-desc') {
                    //  Use numeric comparison.
                    return parseInt(bKey) - parseInt(aKey);
                } else {
                    return 0;
                }
            });

            for (const item of sorted) {
                list.appendChild(item);
            }
        });

        //  If the radio button is already selected, trigger the `click` event to perform the
        //  initial sort.
        if ((radio as HTMLInputElement).checked) {
            radio.dispatchEvent(new Event('click'));
        }
    });
});
