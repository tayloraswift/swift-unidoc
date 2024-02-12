extension Markdown.Tutorial
{
    final
    class Steps:Markdown.BlockContainer<Step>
    {
        init()
        {
            super.init([])
        }
    }
}
extension Markdown.Tutorial.Steps:Markdown.BlockDirectiveType
{
    /// Always throws an error, as this directive does not support any options.
    public
    func configure(option:String, value:String) throws
    {
        throw ArgumentError.unexpected(option)
    }

    public
    func append(_ element:Markdown.BlockElement) throws
    {
        guard
        case let step as Markdown.Tutorial.Step = element
        else
        {
            throw StructuralError.step(type: type(of: element))
        }

        self.elements.append(step)
    }
}
