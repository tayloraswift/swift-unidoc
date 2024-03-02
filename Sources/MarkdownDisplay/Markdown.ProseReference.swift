import MarkdownABI

extension Markdown
{
    /// A `ProseReference` is an abstraction over a raw ``Int`` bytecode reference. It uses tag
    /// bits to represent the preview card display mode.
    ///
    /// The tags live in bits 24 through 31. As markdown bytecode references use a
    /// variable-length encoding, this means card references always take 4 bytes to encode. This
    /// also limits the total number of outlined references to 16,777,215. Documents that
    /// contain that many references are certain to run into other capacity limits long before
    /// they reach this limit.
    @frozen public
    struct ProseReference:Sendable
    {
        @usableFromInline
        var reference:Int

        @inlinable public
        init(_ reference:Int)
        {
            self.reference = reference
        }
    }
}
extension Markdown.ProseReference
{
    @inlinable static
    var card:Int { 0x01_00_00_00 }
}
extension Markdown.ProseReference
{
    @inlinable public static
    func card(_ index:Int) -> Self
    {
        precondition(0 ... 0x00_FF_FF_FF ~= index)
        return .init(index | Self.card)
    }

    @inlinable public static
    func &= (binary:inout Markdown.BinaryEncoder, self:Self)
    {
        binary &= self.reference
    }
}
extension Markdown.ProseReference
{
    @inlinable public
    var index:Int { self.reference & 0x00_FF_FF_FF }

    @inlinable public
    var card:Bool
    {
        Self.card == self.reference & 0xFF_00_00_00
    }
}
