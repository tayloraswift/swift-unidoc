@frozen public
struct IdentifierLexeme:LosslessStringConvertible, Equatable, Hashable, Sendable
{
    public
    let description:String

    @inlinable internal
    init(unchecked description:String)
    {
        self.description = description
    }
}
extension IdentifierLexeme
{
    @inlinable public static
    var underscore:Self { .init(unchecked: "_") }

    public
    init?(_ description:String)
    {
        guard   let first:Unicode.Scalar = description.unicodeScalars.first,
                let _:First = .init(first)
        else
        {
            return nil
        }
        for codepoint:Unicode.Scalar in description.unicodeScalars.dropFirst()
        {
            guard let _:Element = .init(codepoint)
            else
            {
                return nil
            }
        }

        self.description = description
    }
}
extension IdentifierLexeme:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.description < rhs.description
    }
}
