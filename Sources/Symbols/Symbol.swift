@available(*, deprecated, renamed: "Symbol.File")
public
typealias UnifiedSymbol = Symbol

/// A unified symbol resolution (USR).
@frozen public
enum Symbol:Hashable, Equatable, Sendable
{
    /// A declaration vector. The compiler calls these synthesized
    /// value-declarations.
    case vector(Decl.Vector)

    /// A declaration scalar. The compiler calls these value-declarations.
    case scalar(Decl)

    /// An extension block. The payload is everything after the
    /// `s:e:` prefix, including any colons and special characters.
    /// The compiler calls these extension-declarations.
    case block(Block)
}
extension Symbol:CustomStringConvertible
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
extension Symbol:LosslessStringConvertible
{
    public
    init?(_ description:String)
    {
        if  let block:Symbol.Block = .init(description)
        {
            self = .block(block)
            return
        }

        let fragments:[Substring] = description.split(separator: ":",
            omittingEmptySubsequences: true)

        if      let scalar:Symbol.Decl = .init(fragments: fragments)
        {
            self = .scalar(scalar)
        }
        else if let vector:Symbol.Decl.Vector = .init(fragments: fragments)
        {
            self = .vector(vector)
        }
        else
        {
            return nil
        }
    }
}
