import MarkdownABI

extension Markdown
{
    public final
    class BlockDirective:BlockContainer<BlockElement>
    {
        public
        var name:String
        public
        var arguments:[(name:String, value:String)]

        @inlinable public
        init(name:String,
            arguments:[(name:String, value:String)] = [],
            elements:[BlockElement] = [])
        {
            self.name = name
            self.arguments = arguments
            super.init(elements)
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
