extension Codelink
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        public
        var components:PathComponents<Component>
        public
        var collation:Collation?

        private
        init(components:PathComponents<Component>, collation:Collation? = nil)
        {
            self.components = components
            self.collation = collation
        }
    }
}
extension Codelink.Path
{
    init?(_ description:Substring, suffix:inout Suffix?)
    {
        var codepoints:Substring.UnicodeScalarView = description.unicodeScalars

        if  let first:Component = .init(parsing: &codepoints)
        {
            self.init(components: .init([], first))
        }
        else
        {
            return nil
        }

        while let separator:Unicode.Scalar = codepoints.popFirst()
        {
            switch (self.components.last, separator, suffix)
            {
            case (_,                "-", nil):
                self.collation = .legacy
                suffix = .init(.init(codepoints))
                if case nil = suffix
                {
                    return nil
                }
                else
                {
                    //  we know we already consumed all remaining input
                    return
                }

            case (.nominal(_, nil), "/", nil):
                self.collation = .legacy
                fallthrough
            
            case (.nominal(_, nil), ".", _):
                if  let next:Component = .init(parsing: &codepoints)
                {
                    self.components.append(next)
                    continue
                }
                else
                {
                    return nil
                }
            
            default:
                return nil
            }
        }

        if !codepoints.isEmpty
        {
            return nil
        }
    }
}
