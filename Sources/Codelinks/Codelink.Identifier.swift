extension Codelink
{
    @frozen public
    struct Identifier:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        var characters:String

        @inlinable public
        init(head:Head)
        {
            self.characters = .init(head.codepoint)
        }
    }
}
extension Codelink.Identifier
{
    @inlinable public static
    var underscore:Self { .init(head: .init(codepoint: "_")) }

    @inlinable public mutating
    func append(_ next:Element)
    {
        self.characters.append(Character.init(next.codepoint))
    }
}
extension Codelink.Identifier:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.characters < rhs.characters
    }
}
extension Codelink.Identifier:LosslessStringConvertible
{
    @inlinable public
    var description:String
    {
        self.characters
    }

    public
    init?(_ description:String)
    {
        self.init(description[...])
    }
}
extension Codelink.Identifier
{
    public
    init?(_ description:Substring)
    {
        var codepoints:Substring.UnicodeScalarView = description.unicodeScalars
        self.init(parsing: &codepoints)
        if !codepoints.isEmpty
        {
            return nil
        }
    }

    init?(parsing codepoints:inout Substring.UnicodeScalarView)
    {
        guard   let head:Unicode.Scalar = codepoints.first,
                let head:Head = .init(head)
        else
        {
            return nil
        }

        codepoints.removeFirst()
        self.init(head: head)

        while   let next:Unicode.Scalar = codepoints.first,
                let next:Element = .init(next)
        {
            codepoints.removeFirst()
            self.append(next)
        }
    }
}
