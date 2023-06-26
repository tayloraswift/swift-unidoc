@available(*, deprecated, renamed: "Symbol.Decl.Vector")
public
typealias VectorSymbol = Symbol.Decl.Vector

extension Symbol.Decl
{
    /// A vector symbol resolution.
    @frozen public
    struct Vector:Equatable, Hashable
    {
        public
        let feature:Symbol.Decl
        public
        let heir:Symbol.Decl

        @inlinable public
        init(_ feature:Symbol.Decl, self heir:Symbol.Decl)
        {
            self.feature = feature
            self.heir = heir
        }
    }
}
extension Symbol.Decl.Vector:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.feature.description)::SYNTHESIZED::\(self.heir.description)"
    }
}
extension Symbol.Decl.Vector:LosslessStringConvertible
{
    public
    init?(_ description:__shared String)
    {
        self.init(fragments: description.split(separator: ":", maxSplits: 4,
            omittingEmptySubsequences: true))
    }
    init?(fragments:__shared [Substring])
    {
        if  fragments.count == 5,
            let language:Unicode.Scalar = .init(fragments[0]),
            let member:Symbol.Decl = .init(language, fragments[1]),
            fragments[2] == "SYNTHESIZED",
            let language:Unicode.Scalar = .init(fragments[3]),
            let heir:Symbol.Decl = .init(language, fragments[4])
        {
            self.init(member, self: heir)
        }
        else
        {
            return nil
        }
    }
}
