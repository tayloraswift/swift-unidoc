import Symbols

extension Phylum.DeclFlags {
    /// A mocking shortcut for creating a ``Phylum.DeclFlags``.
    @inlinable public static func swift(
        _ phylum: Phylum.Decl,
        kinks: Phylum.Decl.Kinks = [],
        route: Phylum.Decl.Route = .init(underscored: false, hashed: false)
    ) -> Self {
        .init(language: .swift, phylum: phylum, kinks: kinks, route: route)
    }
}
