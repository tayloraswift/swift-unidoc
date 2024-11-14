import { Searchbar } from './Searchbar';

function hex(value: number): string {
    return value.toString(16).padStart(2, "0")
}

function nonce(): string {
    const uint64: Uint8Array = new Uint8Array(8);
    return Array.from(window.crypto.getRandomValues(uint64), hex).join('')
}

function textfield(element: Element | null): boolean {
    if (element === null) {
        return false;
    }

    if (element instanceof HTMLInputElement) {
        switch (element.type) {
            case 'text':
            case 'search':
            case 'password':
            case 'number':
            case 'email':
            case 'tel':
            case 'url':
            case 'search':
            case 'date':
            case 'datetime':
            case 'datetime-local':
            case 'time':
            case 'month':
            case 'week':
                return true;

            default:
                return false;
        }
    }
    if (element instanceof HTMLTextAreaElement) {
        return true;
    } else {
        return false;
    }
}

const tooltips: HTMLElement | null = document.getElementById('ss:tooltips');
const search: HTMLElement | null = document.getElementById('search');
const login: HTMLElement | null = document.getElementById('login');
const intrapageNavigator: HTMLElement | null = document.getElementById('sidebar-intrapage');
const main: HTMLElement | null = document.querySelector('main');

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
            let active: Element | null = document.activeElement;
            switch (event.key) {
                case 'Escape': {
                    if (active === input) {
                        input.blur();
                    }
                    break;
                }
                case '/': {
                    //  This should only be in effect if no text input is already focused.
                    if (active !== input && !textfield(active)) {
                        input.focus();
                        event.preventDefault();
                    }
                    break;
                }
                case ',': {
                    if (searchbar.mode !== null && (active === input || !textfield(active))) {
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

if (tooltips !== null) {
    tooltips.remove();
    //  The tooltips `<div>` contains `<a>` elements only.
    let cards: { [id: string] : HTMLSpanElement; } = {};
    let frame: HTMLDivElement = document.createElement('div');

    for (const anchor of tooltips.children) {
        if (!(anchor instanceof HTMLAnchorElement)) {
            continue;
        }

        //  Cannot use `anchor.href`, we want the exact value of the `href` attribute.
        const id: string | null = anchor.getAttribute("href")

        if (id === null) {
            continue;
        }

        //  Change the tooltip into a `<div>` with `class="tooltip"`.
        const tooltip: HTMLDivElement = document.createElement('div');
        tooltip.innerHTML = anchor.innerHTML;

        cards[id] = tooltip;
        frame.appendChild(tooltip);
    }

    //  Inject the tooltips into every `<a>` element with the same `href` attribute.
    //  This should only be done within the `<main>` element.
    if (main !== null) {
        main.querySelectorAll('a').forEach((
                anchor: HTMLAnchorElement,
                key: number,
                all: NodeListOf<Element>
            ) => {

            let overview: boolean = true;

            //  Check if the anchor has a `data-tooltip` mode set.
            if (anchor.dataset.tooltip !== undefined) {
                if  (anchor.dataset.tooltip === 'n') {
                    return;
                }
                if  (anchor.dataset.tooltip === 'd') {
                    overview = false;
                }
            }

            const id: string | null = anchor.getAttribute("href")

            if (id === null) {
                return;
            }
            const tooltip: HTMLSpanElement | undefined = cards[id];

            if (tooltip === undefined) {
                return;
            }

            //  When you hover over the anchor, show the tooltip by loading the (x, y) position
            //  of the anchor on the screen, and then adding the tooltip to the document as
            //  a fixed-position element.
            anchor.addEventListener('mouseenter', (event: MouseEvent) => {
                const r: DOMRect = anchor.getBoundingClientRect();

                const width: number = window.innerWidth
                //  If the anchor is more than halfway across the screen, flow the tooltip to
                //  the left instead of the right.

                if (r.left > width / 2) {
                    tooltip.style.right = (width - r.right).toString() + 'px';
                    tooltip.style.left = 'auto';
                } else {
                    tooltip.style.right = 'auto';
                    tooltip.style.left = r.x.toString() + 'px';
                }

                tooltip.style.top = r.bottom.toString() + 'px';

                if (overview) {
                    tooltip.classList.add('overview');
                } else {

                    tooltip.classList.remove('overview');
                }

                tooltip.classList.add('visible');
            });
            anchor.addEventListener('mouseleave', (event: MouseEvent) => {
                tooltip.classList.remove('visible');
            });
        });

        //  Make the tooltips list visible; it was originally hidden to prevent FOUC.
        frame.className = 'tooltips';
        document.body.appendChild(frame);
    }
}

if (intrapageNavigator !== null && main !== null) {
    //  Find every heading (`<h2>` through `<h4>`) that has an `id` attribute, within a `<main>`
    //  element.
    let list: HTMLOListElement = document.createElement('ol');

    list.classList.add('table-of-contents');

    const title: HTMLLIElement = document.createElement('li');
    title.classList.add('title');

    const top: HTMLAnchorElement = document.createElement('a');
    top.href = '#';
    top.textContent = 'On this page';

    title.appendChild(top);
    list.appendChild(title);

    let headingElements: HTMLElement[] = [];
    let listElements: HTMLLIElement[] = [];

    let culturesSeen: Set<string> = new Set();

    main.querySelectorAll('header, h2[id], h3[id], h4[id]').forEach((
            header: Element,
            key: number,
            all: NodeListOf<Element>
        ) => {

        if (!(header instanceof HTMLElement)) {
            return;
        }

        //  Create a list item for the link.
        const item: HTMLLIElement = document.createElement('li');

        //  Create a link to the heading.
        const anchor: HTMLAnchorElement = document.createElement('a');
        anchor.href = '#' + header.id;

        if (header instanceof HTMLHeadingElement) {
            item.classList.add(header.tagName.toLowerCase());
            anchor.textContent = header.textContent;
        } else {
            item.classList.add('group');

            //  Find the module name.
            const culture: HTMLAnchorElement | null = header.querySelector('h2 a[href^="/"]');

            if (culture === null) {
                return;
            }

            //  If we have already seen this culture, we can skip rendering the module name,
            //  to save vertical space.
            if (!culturesSeen.has(culture.href)) {
                culturesSeen.add(culture.href);

                const module: HTMLSpanElement = document.createElement('span');
                module.textContent = culture.textContent;

                anchor.appendChild(module);
            }

            //  Find the generic where clause, if present.
            const clause: HTMLDivElement | null = header.querySelector('h2 + div');

            if (clause !== null) {
                const where: HTMLElement = document.createElement('code');
                where.textContent = clause.textContent;

                anchor.appendChild(where);
            }
        }

        item.appendChild(anchor);

        //  Append the list item to the intrapage navigator.
        list.appendChild(item);

        headingElements.push(header);
        listElements.push(item);
    });

    intrapageNavigator.appendChild(list);

    //  When the document is scrolled, highlight the anchors associated with the visible
    //  headings in the intrapage navigator. This is the last heading with a negative viewport
    //  position, through the last heading with a viewport position less than the height of the
    //  viewport.
    document.addEventListener('scroll', (event: Event) => {
        const viewportMinimum: number = main.offsetTop;
        const viewportHeight: number = window.innerHeight;
        let partiallyVisible: boolean = true;

        for (let i = headingElements.length - 1; i >= 0; i--) {
            const heading: HTMLElement = headingElements[i];
            const rect: DOMRect = heading.getBoundingClientRect();

            const above: boolean = rect.top < viewportMinimum;

            if (rect.top < viewportHeight && (!above || partiallyVisible)) {
                listElements[i].classList.add('active');
            } else {
                listElements[i].classList.remove('active');
            }

            if (above) {
                partiallyVisible = false;
            }
        }
    });

    //  Fire a ceremonial scroll event to initialize the intrapage navigator.
    document.dispatchEvent(new Event('scroll'));
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

//  This is the best way to implement blurable web menus, see
//  https://css-tricks.com/dangers-stopping-event-propagation/#aa-what-to-do-instead
//
//  Note: we didn’t use `<details>`, because toggling that element causes CLS on Firefox.
//  Note: we didn’t use `<input type='checkbox'>` because the semantics of the toggle are
//  closer to `<button>`.
document.querySelectorAll('div.menu').forEach((
        div: Element,
        key: number,
        all: NodeListOf<Element>
    ) => {

    //  The `<div>` should contain one `<button>` direct child.
    let button: HTMLButtonElement | null = null;

    for (const child of div.children) {
        if (child instanceof HTMLButtonElement) {
            button = child;
            break;
        }
    }

    if (button !== null) {
        button.addEventListener('click', (event: Event) => {
            div.classList.toggle('open');
        });
    }
});
document.addEventListener('click', (event: Event) => {
    //  Check if the target of the click event is inside a `div.menu` element.
    let menu: Element | null = null;
    if  (event.target instanceof Element) {
        menu = event.target.closest('div.menu');
    }
    //  Remove the `open` class from all `div.menu` elements that are not `menu`.
    document.querySelectorAll('div.menu').forEach((
            div: Element,
            key: number,
            all: NodeListOf<Element>
        ) => {
        if (div !== menu) {
            div.classList.remove('open');
        }
    });
});
