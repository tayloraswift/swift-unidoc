import ModuleGraphs
import LexicalPaths

extension CodelinkResolver
{
    @frozen public
    struct Scope
    {
        public
        let namespace:ModuleIdentifier
        public
        let imports:[ModuleIdentifier]
        public
        let path:[String]

        @inlinable public
        init(namespace:ModuleIdentifier, imports:[ModuleIdentifier] = [], path:[String] = [])
        {
            self.namespace = namespace
            self.imports = imports
            self.path = path
        }
    }
}
