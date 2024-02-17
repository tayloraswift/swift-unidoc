extension Markdown.BlockArticle
{
    enum StructuralError:Error
    {
        case intro(type:Markdown.BlockElement.Type)
    }
}
