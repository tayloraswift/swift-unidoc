import Symbols

extension DoclinkResolver
{
    @frozen public
    struct Scope
    {
        public
        let namespace:Symbol.Module?

        @inlinable public
        init(namespace:Symbol.Module?)
        {
            self.namespace = namespace
        }
    }
}
