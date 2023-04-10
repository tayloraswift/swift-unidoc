extension Codelink
{
    @frozen public
    struct Scope:Equatable, Hashable, Sendable
    {
        public
        var components:PathComponents<String>

        private
        init(first:String)
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
            self.init(first: first.characters)
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
                self.components.append(next.characters)
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
