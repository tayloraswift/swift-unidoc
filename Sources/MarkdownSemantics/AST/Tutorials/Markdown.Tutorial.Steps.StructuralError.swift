extension Markdown.Tutorial.Steps
{
    enum StructuralError:Error
    {
        case step(type:Markdown.BlockElement.Type)
    }
}
