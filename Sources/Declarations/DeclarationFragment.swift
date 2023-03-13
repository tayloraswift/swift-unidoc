@frozen public
struct DeclarationFragment<Symbol, Color>:Equatable, Hashable
    where Symbol:Hashable, Color:Hashable
{
    public
    let spelling:String
    public
    let symbol:Symbol?
    public
    let color:Color

    @inlinable public
    init(_ spelling:String, symbol:Symbol?, color:Color)
    {
        self.spelling = spelling
        self.symbol = symbol
        self.color = color
    }
}
extension DeclarationFragment:Sendable where Symbol:Sendable, Color:Sendable
{
}
extension DeclarationFragment:CustomStringConvertible where Color == DeclarationFragmentClass?
{
    public
    var description:String
    {
        "\(self.color?.description ?? "")'\(self.spelling)'"
    }
}
extension DeclarationFragment
{
    @inlinable public
    func map<T>(_ transform:(Symbol) throws -> T) rethrows -> DeclarationFragment<T, Color>
    {
        .init(self.spelling, symbol: try self.symbol.map(transform), color: self.color)
    }
}
