import HTML
import MarkdownABI

extension MarkdownElementContext
{
    struct AttributeContext
    {
        private
        var complete:[(name:HTML.Attribute, value:String)]
        private
        var current:MarkdownBytecode.Attribute?
        private
        var buffer:[UInt8]

        init()
        {
            self.complete = []
            self.current = nil
            self.buffer = []
        }
    }
}
extension MarkdownElementContext.AttributeContext
{
    func contains(_ attribute:HTML.Attribute) -> Bool
    {
        self.complete.contains { $0.name == attribute }
    }

    mutating
    func append(class enumerated:some RawRepresentable<String>)
    {
        self.complete.append((.class, enumerated.rawValue))
    }
    mutating
    func append(value:String, as instruction:MarkdownBytecode.Attribute)
    {
        switch instruction
        {
        case .language: self.complete.append((.class, "language-\(value)"))

        case .checkbox: self.complete.append((.type, "checkbox"))

        case .center:   self.complete.append((.align, "center"))
        case .left:     self.complete.append((.align, "left"))
        case .right:    self.complete.append((.align, "right"))

        case .alt:      self.complete.append((.alt, value))
        case .class:    self.complete.append((.class, value))
        case .checked:  self.complete.append((.checked, value))
        case .disabled: self.complete.append((.disabled, value))
        case .href:     self.complete.append((.href, value))
        case .src:      self.complete.append((.src, value))
        case .title:    self.complete.append((.title, value))

        case .external:
            self.complete.append((.rel, "\(HTML.Attribute.Rel.nofollow)"))
            self.complete.append((.rel, "\(HTML.Attribute.Rel.noopener)"))
            self.complete.append((.rel, "\(HTML.Attribute.Rel.google_ugc)"))
            self.complete.append((.href, value))
        }
    }
}
extension MarkdownElementContext.AttributeContext
{
    mutating
    func buffer(utf8 codeunit:UInt8) -> Void?
    {
        self.current.map { _ in self.buffer.append(codeunit) }
    }
    /// Remove all attributes from the attribute context.
    mutating
    func clear()
    {
        self.complete.removeAll(keepingCapacity: true)
        self.current = nil
        self.buffer.removeAll(keepingCapacity: true)
    }
    /// Closes the current attribute (if any), and appends it to the list of
    /// complete attributes, making it available for encoding.
    mutating
    func flush(beginning next:MarkdownBytecode.Attribute?)
    {
        defer
        {
            self.current = next
        }
        if  let instruction:MarkdownBytecode.Attribute = self.current
        {
            self.append(value: .init(decoding: self.buffer, as: Unicode.UTF8.self),
                as: instruction)
            self.buffer.removeAll(keepingCapacity: true)
        }
    }
}
extension MarkdownElementContext.AttributeContext:MarkdownAttributeContext
{
}
extension MarkdownElementContext.AttributeContext
{
    func encode(to attributes:inout HTML.AttributeEncoder)
    {
        var classes:[String] = []

        for (name, value):(HTML.Attribute, String) in self.complete
        {
            switch name
            {
            case .class:
                classes.append(value)

            default:
                attributes[name: name] = value
            }
        }
        if !classes.isEmpty
        {
            attributes.class = classes.joined(separator: " ")
        }
    }
}
