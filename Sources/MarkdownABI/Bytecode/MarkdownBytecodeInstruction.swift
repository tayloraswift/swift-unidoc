public
protocol MarkdownBytecodeInstruction:RawRepresentable<UInt8>
{
    static
    var marker:MarkdownBytecode.Marker { get }
}
