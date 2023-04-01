import MarkdownABI

public
protocol MarkdownBinaryConvertibleElement
{
    func serialize(into binary:inout MarkdownBinary)
}
