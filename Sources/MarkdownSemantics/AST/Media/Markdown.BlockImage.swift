import Sources

extension Markdown
{
    /// A `BlockImage` is a generalization of Apple’s various `@Image` directives. It renders as
    /// a `<figure>` element containing an `<img>` element and an optional `<figcaption>`
    /// element. Unlike most of the Apple `@Image` directives, it can contain children. The
    /// children go into the `<figcaption>` element.
    final
    class BlockImage:BlockContainer<BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        /// Not to be confused with ``source``.
        private(set)
        var src:Outlinable<SourceString>?
        private(set)
        var alt:String?

        init()
        {
            self.src = nil
            self.alt = nil
            super.init([])
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.figure]
            {
                if  case .outlined(let reference) = self.src
                {
                    $0[.img]
                    {
                        $0[.src] = reference
                        $0[.alt] = self.alt
                    }
                }

                if  self.elements.isEmpty
                {
                    return
                }

                $0[.figcaption]
                {
                    super.emit(into: &$0)
                }
            }
        }

        override
        func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
        {
            //  Not ``AnyReference/filePath(_:)``!
            if  case .inline(let expression) = self.src,
                case let reference? = try register(.file(expression))
            {
                self.src = .outlined(reference)
            }

            try super.outline(by: register)
        }
    }
}
extension Markdown.BlockImage:Markdown.BlockDirectiveType
{
    enum Option:String, Markdown.BlockDirectiveOption
    {
        case src, source
        case alt
    }

    func configure(option:Option, value:Markdown.SourceString) throws
    {
        switch option
        {
        case .src, .source:
            guard case nil = self.src
            else
            {
                throw option.duplicate
            }

            self.src = .inline(value)

        case .alt:
            guard case nil = self.alt
            else
            {
                throw option.duplicate
            }

            self.alt = value.string
        }
    }
}
