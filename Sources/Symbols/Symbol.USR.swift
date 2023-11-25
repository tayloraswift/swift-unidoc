extension Symbol
{
    /// A unified symbol resolution (USR).
    ///
    /// Yes, the full name of the type contains the word “Symbol” twice. As *USR* is a term
    /// of art in the Swift and Clang compilers, it was judged to be the least confusing name
    /// among the possible alternatives.
    @frozen public
    enum USR:Hashable, Equatable, Sendable
    {
        /// A declaration vector. The Swift compiler calls these **synthesized
        /// value-declarations**.
        case vector(Decl.Vector)

        /// A declaration scalar. The Swift compiler calls these **value-declarations**.
        case scalar(Decl)

        /// An extension block. The payload is everything after the
        /// `s:e:` prefix, including any colons and special characters.
        /// The compiler calls these **extension-declarations**.
        case block(Block)
    }
}
extension Symbol.USR:CustomStringConvertible
{
    /// Dispatches to the enum payloads; see the documentation for each payload type.
    @inlinable public
    var description:String
    {
        switch self
        {
        case .vector(let vector):   "\(vector)"
        case .scalar(let scalar):   "\(scalar)"
        case .block(let block):     "\(block)"
        }
    }
}
extension Symbol.USR:LosslessStringConvertible
{
    /// Parses a USR from a string.
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
