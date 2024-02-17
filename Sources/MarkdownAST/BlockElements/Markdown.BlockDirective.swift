import MarkdownABI
import Sources

extension Markdown
{
    /// An untyped block directive.
    public final
    class BlockDirective:BlockContainer<BlockElement>
    {
        public
        var source:SourceReference<Markdown.Source>?

        public
        var name:String
        public
        var arguments:[(name:String, value:String)]

        @inlinable public
        init(name:String)
        {
            self.source = nil
            self.name = name
            self.arguments = []
            super.init([])
        }

        /// Emits a fallback description of the directive.
        @inlinable public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.pre]
            {
                $0[.code] = "<\(self.name)>"

                if !self.arguments.isEmpty
                {
                    $0[.dl]
                    {
                        for (name, value):(String, String) in self.arguments
                        {
                            $0[.dt] = name
                            $0[.dd] = value
                        }
                    }
                }

                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.BlockDirective:Markdown.BlockDirectiveType
{
    @inlinable public
    func configure(option:String, value:String, from _:SourceReference<Markdown.Source>) throws
    {
        self.arguments.append((option, value))
    }

    @inlinable public
    func append(_ element:Markdown.BlockElement) throws
    {
        self.elements.append(element)
    }
}
