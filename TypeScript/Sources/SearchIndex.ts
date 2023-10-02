import { NounMapCulture } from './NounMapCulture';

export interface SearchIndex {
    packages:string[];
    cultures:NounMapCulture[];
    trunk?:string;
}
