import Symbols

extension SSGC
{
    @frozen public
    struct ExtendedType:Equatable, Hashable, Sendable
    {
        public
        let namespace:Symbol.Module
        public
        let type:Symbol.Decl

        init(namespace:Symbol.Module, type:Symbol.Decl)
        {
            self.namespace = namespace
            self.type = type
        }
    }
}
extension SSGC.ExtendedType:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.namespace, lhs.type) < (rhs.namespace, rhs.type)
    }
}
