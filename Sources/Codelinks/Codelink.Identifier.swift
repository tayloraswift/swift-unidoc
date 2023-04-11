extension Codelink
{
    @frozen public
    struct Identifier:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        var characters:String
        /// Indicates if this identifier is encased in backticks.
        public
        var encased:Bool

        @inlinable public
        init(head:Head, encased:Bool = false)
        {
            self.characters = .init(head.codepoint)
            self.encased = encased
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
extension Codelink.Identifier:CustomStringConvertible, LexicalContinuation
{
    /// Returns the characters of this identifier, with encasing backticks if it
    /// has any.
    @inlinable public
    var description:String
    {
        self.encased ? "`\(self.characters)`" : self.characters
    }
    /// Returns the characters of this identifier, without any encasing backticks.
    @inlinable public
    var unencased:String
    {
        self.characters
    }
}
extension Codelink.Identifier:LosslessStringConvertible
{
    /// Creates a swift identifier by validating the given string.
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

    /// Consumes text from the input string until encountering an
    /// invalid identifier character. If this initializer returns nil,
    /// then it didn’t consume any text.
    init?(parsing codepoints:inout Substring.UnicodeScalarView)
    {
        var remaining:Substring.UnicodeScalarView = codepoints

        let encased:Bool
        let head:Unicode.Scalar?

        switch remaining.popFirst()
        {
        case "`"?:
            encased = true
            head = remaining.popFirst()
        
        case let codepoint:
            encased = false
            head = codepoint
        }

        guard   let head:Unicode.Scalar,
                let head:Head = .init(head)
        else
        {
            return nil
        }

        self.init(head: head, encased: encased)

        while   let next:Unicode.Scalar = remaining.first,
                let next:Element = .init(next)
        {
            remaining.removeFirst()
            self.append(next)
        }

        if  encased, remaining.popFirst() != "`"
        {
            return nil
        }
        
        codepoints = remaining
    }
}
