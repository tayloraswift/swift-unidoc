import LexicalPaths

extension CodelinkV3
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
extension CodelinkV3.Scope
{
    /// Adds backticks to the last scope component, if necessary.
    private
    init(prefix:consuming [String], normalizing last:String)
    {
        let prefix:[String] = prefix
        if  prefix.isEmpty,
            let _:CodelinkV3.Keyword = .init(rawValue: last)
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
        let first:CodelinkV3.Identifier = .init(parsing: &codepoints)
        else
        {
            return nil
        }

        var prefix:[String] = []
        var last:String = (consume first).unencased

        while let separator:Unicode.Scalar = codepoints.popFirst()
        {
            if  separator == ".",
                let next:CodelinkV3.Identifier = .init(parsing: &codepoints)
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
extension CodelinkV3.Scope:CustomStringConvertible
{
    public
    var description:String
    {
        self.components.joined(separator: ".")
    }
}
