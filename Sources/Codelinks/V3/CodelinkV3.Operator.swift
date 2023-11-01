extension CodelinkV3
{
    @frozen public
    struct Operator:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        var characters:String

        //  Internal, because `.` is not a valid operator.
        init(head:Head)
        {
            self.characters = .init(head.codepoint)
        }
    }
}
extension CodelinkV3.Operator
{
    mutating
    func append(_ next:Element)
    {
        self.characters.append(Character.init(next.codepoint))
    }
}
extension CodelinkV3.Operator:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.characters < rhs.characters
    }
}
extension CodelinkV3.Operator:LosslessStringConvertible
{
    @inlinable public
    var description:String
    {
        self.characters
    }
    /// Creates a swift operator name by validating the given string.
    /// This initializer checks for unconditionally invalid operator
    /// tokens (`.`, `=`, `->`, `//`, `/*`, `*/`), but it doesn’t
    /// check for conditionally invalid prefix, infix, or postfix
    /// tokens.
    public
    init?(_ description:String)
    {
        self.init(description[...])
    }
}
extension CodelinkV3.Operator
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
    /// Consumes text from the input string until encountering an
    /// invalid operator character. If this initializer returns nil,
    /// then it didn’t consume any text.
    init?(parsing codepoints:inout Substring.UnicodeScalarView)
    {
        guard   let head:Unicode.Scalar = codepoints.first,
                let head:Head = .init(head)
        else
        {
            return nil
        }

        self.init(head: head)

        var remaining:Substring.UnicodeScalarView = codepoints.dropFirst()

        while   let next:Unicode.Scalar = remaining.first,
                let next:Element = .init(next),
                head.codepoint == "." || next.codepoint != "."
        {
            remaining.removeFirst()
            self.append(next)
        }

        switch self.characters
        {
        case ".", "=", "->", "//", "/*", "*/":
            return nil
        default:
            codepoints = remaining
        }
    }
}
