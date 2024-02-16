import MarkdownAST
import Sources

extension Markdown.Tutorial
{
    public final
    class Steps:Markdown.BlockContainer<Step>
    {
        public
        var source:SourceReference<Markdown.Source>?

        init()
        {
            self.source = nil
            super.init([])
        }

        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.ol, { $0[.class] = "steps" }]
            {
                super.emit(into: &$0)
            }
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
