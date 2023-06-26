import Symbols

extension Compiler
{
    @frozen public
    struct ExtendedType:Equatable, Hashable, Sendable
    {
        public
        let namespace:Namespace.ID
        public
        let type:Symbol.Decl

        init(namespace:Namespace.ID, type:Symbol.Decl)
        {
            self.namespace = namespace
            self.type = type
        }
    }
}
extension Compiler.ExtendedType:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.namespace, lhs.type) < (rhs.namespace, rhs.type)
    }
}
