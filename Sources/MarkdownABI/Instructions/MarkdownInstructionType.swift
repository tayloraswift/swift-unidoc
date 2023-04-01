public
protocol MarkdownInstructionType<RawValue>
{
    associatedtype RawValue

    static
    var marker:MarkdownBytecode.Marker { get }
    var rawValue:RawValue { get }
}
