public
protocol MarkdownFlavor
{
    static
    func parse(_ string:String) -> [MarkdownBlock]
}
