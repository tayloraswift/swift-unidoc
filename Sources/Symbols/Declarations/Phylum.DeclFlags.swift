extension Phylum
{
    @frozen public
    struct DeclFlags:Equatable, Sendable
    {
        public
        let language:Language
        public
        let phylum:Decl
        public
        let kinks:Decl.Kinks
        public
        var route:Decl.Route

        @inlinable public
        init(language:Language, phylum:Decl, kinks:Decl.Kinks, route:Decl.Route)
        {
            self.language = language
            self.phylum = phylum
            self.kinks = kinks
            self.route = route
        }
    }
}
extension Phylum.DeclFlags
{
    @inlinable package static
    func swift(_ flags:Phylum.SwiftFlags) -> Self
    {
        .init(language: .swift, phylum: flags.phylum, kinks: flags.kinks, route: flags.route)
    }

    /// Indicates whether the declaration should be considered an implementation detail.
    /// The default behavior depends on the language.
    @inlinable public
    var detail:Bool
    {
        switch self.language
        {
        case .swift:    self.route.underscored
        case .c:        true
        case .cpp:      true
        }
    }

    /// Indicates whether the declaration is a C or C++ declaration.
    @inlinable public
    var cdecl:Bool
    {
        switch self.language
        {
        case .swift:    false
        case .c:        true
        case .cpp:      true
        }
    }
}
extension Phylum.DeclFlags:RawRepresentable
{
    @inlinable public
    var rawValue:Int32
    {
        .init(self.language.rawValue) << 24 |
        .init(self.phylum.rawValue) << 16 |
        .init(self.kinks.rawValue) << 8 |
        .init(self.route.rawValue)
    }
    @inlinable public
    init?(rawValue:Int32)
    {
        if  let language:Phylum.Language = .init(rawValue: rawValue >> 24),
            let phylum:Phylum.Decl = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 16)),
            let kinks:Phylum.Decl.Kinks = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 8)),
            let route:Phylum.Decl.Route = .init(
                rawValue: .init(truncatingIfNeeded: rawValue))
        {
            self.init(language: language, phylum: phylum, kinks: kinks, route: route)
        }
        else
        {
            return nil
        }
    }
}
