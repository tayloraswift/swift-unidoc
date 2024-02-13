import HTML
import MarkdownABI
import URI

extension Markdown.TreeContext
{
    struct AttributeList
    {
        private(set)
        var others:[(name:HTML.Attribute, value:String)]
        //  TODO: measure if we would be better off accumulating into a single string.
        private(set)
        var classes:[String]
        private(set)
        var style:String
        private(set)
        var href:String?
        private(set)
        var id:URI.Fragment?

        init()
        {
            self.others = []
            self.classes = []
            self.style = ""
            self.href = nil
            self.id = nil
        }
    }
}
extension Markdown.TreeContext.AttributeList
{
    mutating
    func append(class enumerated:some RawRepresentable<String>)
    {
        self.classes.append(enumerated.rawValue)
    }
    mutating
    func append(value:consuming String, as instruction:Markdown.Bytecode.Attribute)
    {
        switch instruction
        {
        case .language: self.classes.append("language-\(value)")

        case .checkbox: self.others.append((.type, "checkbox"))

        case .center:   self.others.append((.align, "center"))
        case .left:     self.others.append((.align, "left"))
        case .right:    self.others.append((.align, "right"))

        case .alt:      self.others.append((.alt, value))
        case .class:    self.classes.append(value)
        case .checked:  self.others.append((.checked, value))
        case .disabled: self.others.append((.disabled, value))
        case .href:     self.href = value
        case .id:       self.id = .init(rawValue: value)
        case .src:      self.others.append((.src, value))
        case .title:    self.others.append((.title, value))

        case .style:    self.style += value

        case .external:
            self.others.append((.rel, "\(HTML.Attribute.Rel.nofollow)"))
            self.others.append((.rel, "\(HTML.Attribute.Rel.noopener)"))
            self.others.append((.rel, "\(HTML.Attribute.Rel.google_ugc)"))
            self.others.append((.href, value))
        }
    }

    mutating
    func removeAll(keepingCapacity keepCapacity:Bool)
    {
        self.others.removeAll(keepingCapacity: keepCapacity)
        self.classes.removeAll(keepingCapacity: keepCapacity)
        self.style.removeAll(keepingCapacity: keepCapacity)
        self.href = nil
        self.id = nil
    }
}
extension Markdown.TreeContext.AttributeList
{
    func encode(to attributes:inout HTML.AttributeEncoder)
    {
        attributes.class = self.classes.isEmpty ? nil : self.classes.joined(separator: " ")
        attributes.style = self.style.isEmpty ? nil : self.style
        attributes.href = self.href
        attributes.id = self.id?.encoded

        for (name, value):(HTML.Attribute, String) in self.others
        {
            attributes[name: name] = value
        }
    }
}
