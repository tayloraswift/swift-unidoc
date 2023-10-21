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
