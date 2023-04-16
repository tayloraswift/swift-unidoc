extension SymbolGraph
{
    /// A grid position within a source file. This type can represent
    /// positions in files up to one million lines long, and 4096
    /// characters wide.
    @frozen public
    struct SourcePosition
    {
        /// Contains the line number in the upper 20 bits, and
        /// the column index in the lower 12 bits.
        public
        let rawValue:UInt32

        @inlinable public
        init(rawValue:UInt32)
        {
            self.rawValue = rawValue
        }
    }
}
extension SymbolGraph.SourcePosition
{
    var line:Int
    {
        .init(self.rawValue >> 12)
    }
    var column:Int
    {
        .init(self.rawValue & 0x0000_0fff)
    }
}
extension SymbolGraph.SourcePosition
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
            self.init(rawValue: .init(line) << 12 | .init(column))
        }
        else
        {
            return nil
        }
    }
}
