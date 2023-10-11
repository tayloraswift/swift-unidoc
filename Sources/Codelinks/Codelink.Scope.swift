import LexicalPaths

extension Codelink
{
    @frozen public
    struct Scope:Equatable, Hashable, Sendable
    {
        public
        let components:LexicalComponents<Identifier>

        private
        init(components:LexicalComponents<Identifier>)
        {
            self.components = components
        }
    }
}
extension Codelink.Scope
{
    /// Adds backticks to the last scope component, if necessary.
    private
    init(prefix:consuming [String], normalizing last:String)
    {
        let prefix:[String] = prefix
        if  prefix.isEmpty,
            let _:Codelink.Keyword = .init(rawValue: last)
        {
            self.init(components: .init([], .init(characters: last, encased: true)))
        }
        else
        {
            self.init(components: .init(prefix, .init(characters: last, encased: false)))
        }
    }

    init?(_ components:consuming [String])
    {
        guard
        let last:String = components.popLast()
        else
        {
            return nil
        }

        self.init(prefix: components, normalizing: last)
    }

    init?(_ description:Substring)
    {
        var codepoints:Substring.UnicodeScalarView = description.unicodeScalars

        guard
        let first:Codelink.Identifier = .init(parsing: &codepoints)
        else
        {
            return nil
        }

        var prefix:[String] = []
        var last:String = (consume first).unencased

        while let separator:Unicode.Scalar = codepoints.popFirst()
        {
            if  separator == ".",
                let next:Codelink.Identifier = .init(parsing: &codepoints)
            {
                prefix.append(consume last)
                last = next.unencased
            }
            else
            {
                return nil
            }
        }

        guard codepoints.isEmpty
        else
        {
            return nil
        }

        self.init(prefix: prefix, normalizing: last)
    }
}
extension Codelink.Scope:CustomStringConvertible
{
    public
    var description:String
    {
        self.components.joined(separator: ".")
    }
}
