/// A unified symbol resolution (USR).
@frozen public
enum UnifiedSymbol:Hashable, Equatable, Sendable
{
    /// A declaration vector. The compiler calls these synthesized
    /// value-declarations.
    case vector(VectorSymbol)

    /// A declaration scalar. The compiler calls these value-declarations.
    case scalar(ScalarSymbol)

    /// An extension block. The payload is everything after the
    /// `s:e:` prefix, including any colons and special characters.
    /// The compiler calls these extension-declarations.
    case block(BlockSymbol)
}
extension UnifiedSymbol:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .vector(let vector):   return vector.description
        case .scalar(let scalar):   return scalar.description
        case .block(let block):     return block.description
        }
    }
}
extension UnifiedSymbol:LosslessStringConvertible
{
    public
    init?(_ description:String)
    {
        if  let block:BlockSymbol = .init(description)
        {
            self = .block(block)
            return
        }

        let fragments:[Substring] = description.split(separator: ":",
            omittingEmptySubsequences: true)
        
        if      let scalar:ScalarSymbol = .init(fragments: fragments)
        {
            self = .scalar(scalar)
        }
        else if let vector:VectorSymbol = .init(fragments: fragments)
        {
            self = .vector(vector)
        }
        else
        {
            return nil
        }
    }
}
