import Symbols

extension CodelinkResolver
{
    @frozen public
    struct Scope
    {
        public
        let namespace:Symbol.Module
        public
        let imports:[Symbol.Module]
        public
        let path:[String]

        @inlinable public
        init(namespace:Symbol.Module, imports:[Symbol.Module] = [], path:[String] = [])
        {
            self.namespace = namespace
            self.imports = imports
            self.path = path
        }
    }
}
