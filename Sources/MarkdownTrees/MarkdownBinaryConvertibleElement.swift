import MarkdownABI

public
protocol MarkdownBinaryConvertibleElement
{
    func emit(into binary:inout MarkdownBinary)
}
