import LexicalPaths

extension Codelink
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        public
        var components:LexicalComponents<Component>

        @inlinable public
        init(components:LexicalComponents<Component>)
        {
            self.components = components
        }
    }
}
extension Codelink.Path
{
    init?(_ description:Substring, format:inout Format, suffix:inout Codelink.Suffix?)
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
                format = .legacy
                suffix = .init(.init(codepoints))
                //  we know we already consumed all remaining input
                return

            case (.nominal(_, nil), "/", nil):
                format = .legacy
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
extension Codelink.Path:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.components.joined(separator: ".")
    }
}
