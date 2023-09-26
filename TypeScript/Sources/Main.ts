import { Searchbar } from './Searchbar';

function hex(value: number): string {
    return value.toString(16).padStart(2, "0")
}

function nonce(): string {
    const uint64: Uint8Array = new Uint8Array(8);
    return Array.from(window.crypto.getRandomValues(uint64), hex).join('')
}

const login: HTMLElement | null = document.getElementById('login');
const list: HTMLElement | null = document.getElementById('search-results');

if (list !== null) {
    const searchbar: Searchbar = new Searchbar({ list: list });

    const input: HTMLElement | null = document.getElementById('search-input');

    if (input !== null) {
        input.addEventListener('focus', (event: Event) => searchbar.focus());

        //  We don’t want to suggest a keyboard shortcut if the user focused the input
        //  via touch, or if they were already using the keyboard shortcut.
        input.addEventListener('mousedown', function (event: Event) {
             input.setAttribute('placeholder', 'search shortcut: /');
        });

        input.addEventListener('blur', function (event: Event) {
             input.setAttribute('placeholder', 'search symbols');
        });

        input.addEventListener('input', (event: Event) => searchbar.suggest(event));
        input.addEventListener('keydown', (event: KeyboardEvent) => searchbar.navigate(event));

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
            }
        });
    }

    const form: HTMLElement | null = document.getElementById('search');

    if (form !== null) {
        form.addEventListener('submit',
            (event: Event) => searchbar.follow(event));
    }
}

if (login !== null) {

    const input: HTMLElement = document.createElement('input');
    const state: string = nonce();

    input.setAttribute('type', 'hidden');
    input.setAttribute('name', 'state');
    input.setAttribute('value', state);

    login.appendChild(input);

    document.cookie = 'login_state=' + state + '; Path=/ ; SameSite=Lax';
    // document.cookie = 'login_state=' + state + '; Path=/ ; SameSite=Lax ; Secure';
}
