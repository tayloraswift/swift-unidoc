import Symbols
import UCF

extension UCF
{
    @frozen public
    struct ResolutionScope
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
