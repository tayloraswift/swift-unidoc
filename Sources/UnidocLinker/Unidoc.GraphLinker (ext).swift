import UnidocLinking

extension Unidoc.GraphLinker where Self == Unidoc.DynamicLinker {
    @inlinable public static var dynamic: Self { .init() }
}
