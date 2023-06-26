/// A zero-indexed grid position within a source file. This type
/// can represent positions in files up to one million lines long,
/// and 4096 characters wide.
@frozen public
struct SourcePosition:Equatable, Hashable, Sendable
{
    /// Contains the line number in the upper 20 bits, and
    /// the column index in the lower 12 bits.
    public
    let bits:UInt32

    @inlinable public
    init(bits:UInt32)
    {
        self.bits = bits
    }
}
extension SourcePosition:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.bits < rhs.bits
    }
}
extension SourcePosition:RawRepresentable
{
    @inlinable public
    var rawValue:Int32
    {
        .init(bitPattern: self.bits)
    }
    @inlinable public
    init(rawValue:Int32)
    {
        self.init(bits: .init(bitPattern: rawValue))
    }
}
extension SourcePosition
{
    @inlinable public static
    var zero:Self { .init(bits: 0) }
}
extension SourcePosition
{
    @inlinable public
    var line:Int
    {
        .init(0xffff_f___ & self.bits >> 12)
    }
    @inlinable public
    var column:Int
    {
        .init(0x0000_0fff & self.bits)
    }
}
extension SourcePosition
{
    /// Creates a source position encoding the specified line number
    /// and column index. This initializer returns nil if the line
    /// number is greater than `1048575`, or the column index is
    /// greater than `4096`.
    @inlinable public
    init?(line:Int, column:Int)
    {
        if  0 ..< 0xffff_f___ ~= line,
            0 ..< 0x0000_0fff ~= column
        {
            self.init(bits: .init(line) << 12 | .init(column))
        }
        else
        {
            return nil
        }
    }
}
extension SourcePosition:CustomStringConvertible
{
    /// Prints a human-friendly description of this source position
    /// by adding `1` to the line and column numbers.
    public
    var description:String
    {
        "\(self.line + 1):\(self.column + 1)"
    }
}
