/// A vector symbol resolution.
@frozen public
struct VectorSymbol:Equatable, Hashable
{
    public
    let feature:ScalarSymbol
    public
    let heir:ScalarSymbol

    @inlinable public
    init(_ feature:ScalarSymbol, self heir:ScalarSymbol)
    {
        self.feature = feature
        self.heir = heir
    }
}
extension VectorSymbol:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.feature.description)::SYNTHESIZED::\(self.heir.description)"
    }
}
extension VectorSymbol:LosslessStringConvertible
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
            let member:ScalarSymbol = .init(language, fragments[1]),
            fragments[2] == "SYNTHESIZED",
            let language:Unicode.Scalar = .init(fragments[3]),
            let heir:ScalarSymbol = .init(language, fragments[4])
        {
            self.init(member, self: heir)
        }
        else
        {
            return nil
        }
    }
}
