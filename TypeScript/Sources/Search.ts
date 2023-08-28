import { Searchbar } from './Searchbar';

const list: HTMLElement | null = document.getElementById('search-results');

if (list !== null) {
    const searchbar: Searchbar = new Searchbar({ list: list });

    const input: HTMLElement | null = document.getElementById('search-input');

    if (input !== null) {
        input.addEventListener('focus',
            (event: Event) => searchbar.focus());
        input.addEventListener('input',
            (event: Event) => searchbar.suggest(event));
        input.addEventListener('keydown',
            (event: KeyboardEvent) => searchbar.navigate(event));
    }

    const form: HTMLElement | null = document.getElementById('search');

    if (form !== null) {
        form.addEventListener('submit',
            (event: Event) => searchbar.follow(event));
    }
}

// // prevents clicking on the label from defocusing the search input
// version.addEventListener('mousedown', function(event:Event) {
//         event.preventDefault();
//     });
// // defocuses the search input once the menu is actually toggled (on mouseup)
// versionMenuToggle.addEventListener('change', function(event:Event) {
//         searchInput.blur();
//         //versionMenuToggle.focus();
//         toolbar.toggleVersionMenu(event);
//     });

