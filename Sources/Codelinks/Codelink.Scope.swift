extension Codelink
{
    @frozen public
    struct Scope:Equatable, Hashable, Sendable
    {
        public
        var components:LexicalComponents<Identifier>

        private
        init(first:Identifier)
        {
            self.components = .init([], first)
        }
    }
}
extension Codelink.Scope
{
    init?(_ description:Substring)
    {
        var codepoints:Substring.UnicodeScalarView = description.unicodeScalars

        if  let first:Codelink.Identifier = .init(parsing: &codepoints)
        {
            self.init(first: first)
        }
        else
        {
            return nil
        }

        while let separator:Unicode.Scalar = codepoints.popFirst()
        {
            if  separator == ".",
                let next:Codelink.Identifier = .init(parsing: &codepoints)
            {
                self.components.append(next)
            }
            else
            {
                return nil
            }
        }

        if !codepoints.isEmpty
        {
            return nil
        }
    }
}
extension Codelink.Scope:CustomStringConvertible
{
    public
    var description:String
    {
        if  let keyword:Codelink.Keyword = .init(self)
        {
            return keyword.encased
        }
        else
        {
            return self.components.joined(separator: ".")
        }
    }
}
