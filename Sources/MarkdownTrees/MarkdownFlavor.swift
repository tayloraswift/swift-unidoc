public
protocol MarkdownFlavor
{
    static
    func parse(_ string:String, id:Int) -> [MarkdownBlock]
}
