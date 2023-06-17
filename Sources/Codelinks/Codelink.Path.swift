import LexicalPaths

extension Codelink
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        public
        var components:LexicalComponents<Component>
        public
        var format:Format

        private
        init(components:LexicalComponents<Component>, format:Format = .unidoc)
        {
            self.components = components
            self.format = format
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
                self.format = .legacy
                suffix = .init(.init(codepoints))
                //  we know we already consumed all remaining input
                return

            case (.nominal(_, nil), "/", nil):
                self.format = .legacy
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
