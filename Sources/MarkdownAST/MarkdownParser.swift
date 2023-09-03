public
protocol MarkdownParser
{
    func parse(_ string:String, from id:Int) -> [MarkdownBlock]
}
