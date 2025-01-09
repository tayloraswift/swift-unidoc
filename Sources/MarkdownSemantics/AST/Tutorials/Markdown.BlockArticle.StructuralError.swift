extension Markdown.BlockArticle
{
    enum StructuralError:Error
    {
        case intro(type:Markdown.BlockElement.Type)
    }
}
extension Markdown.BlockArticle.StructuralError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .intro(let type):
            """
            the first block in an article should be an '@Intro', found '\(type)'
            """
        }
    }
}
