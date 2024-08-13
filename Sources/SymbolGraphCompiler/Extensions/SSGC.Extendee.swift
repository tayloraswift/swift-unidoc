import LexicalPaths
import Symbols

extension SSGC
{
    @frozen public
    struct Extendee:Equatable
    {
        /// The module namespace of the extended type. This is not necessarily the culture of
        /// the extended type, if the extended type itself is nested in a type in another
        /// namespace.
        public
        let namespace:Symbol.Module
        /// The full name of the extended type, not including the module namespace prefix.
        public
        let path:UnqualifiedPath
        public
        let id:Symbol.Decl

        init(namespace:Symbol.Module, path:UnqualifiedPath, id:Symbol.Decl)
        {
            self.namespace = namespace
            self.path = path
            self.id = id
        }
    }
}
