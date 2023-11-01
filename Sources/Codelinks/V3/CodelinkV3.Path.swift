import LexicalPaths

extension CodelinkV3
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
extension CodelinkV3.Path
{
    init?(_ description:Substring, format:inout Format, suffix:inout CodelinkV3.Suffix?)
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
                //  We know we already consumed all remaining input.
                return

            case (.nominal(_, nil), "/", nil):
                format = .legacy

                //  Tolerate trailing slash.
                if  codepoints.isEmpty
                {
                    return
                }
                else
                {
                    fallthrough
                }

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
extension CodelinkV3.Path:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.components.joined(separator: ".")
    }
}
