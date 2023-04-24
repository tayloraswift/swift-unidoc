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
    init(_ spelling:String, symbol:Symbol? = nil, color:Color)
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
    func with<Symbol>(symbol:__owned Symbol?) -> DeclarationFragment<Symbol, Color>
    {
        .init(self.spelling, symbol: symbol, color: self.color)
    }
    @inlinable public
    func with<Color>(color:__owned Color) -> DeclarationFragment<Symbol, Color>
    {
        .init(self.spelling, symbol: self.symbol, color: color)
    }

    @inlinable public
    func spelled(_ spelling:__owned String) -> Self
    {
        .init(spelling, symbol: self.symbol, color: self.color)
    }
}
extension DeclarationFragment
{
    @inlinable public
    func map<T>(_ transform:(Symbol) throws -> T) rethrows -> DeclarationFragment<T, Color>
    {
        self.with(symbol: try self.symbol.map(transform))
    }
}
