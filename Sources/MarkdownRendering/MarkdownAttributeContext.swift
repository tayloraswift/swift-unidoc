import HTML
import MarkdownABI

struct MarkdownAttributeContext
{
    private(set)
    var complete:[(name:HTML.Attribute, value:String)]
    var current:(name:MarkdownBytecode.Attribute, utf8:[UInt8])?

    init()
    {
        self.complete = []
        self.current = nil
    }
}
extension MarkdownAttributeContext
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
        }
    }
}
extension MarkdownAttributeContext
{
    /// Remove all attributes from the attribute context.
    mutating
    func clear()
    {
        self.complete.removeAll()
        self.current = nil
    }
    /// Closes the current attribute (if any), and appends it to the list of
    /// complete attributes, making it available for encoding.
    mutating
    func commit()
    {
        defer
        {
            self.current = nil
        }
        if  let (instruction, utf8):(MarkdownBytecode.Attribute, [UInt8]) = self.current
        {
            self.append(value: .init(decoding: utf8, as: Unicode.UTF8.self), as: instruction)
        }
    }
}
extension MarkdownAttributeContext
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
