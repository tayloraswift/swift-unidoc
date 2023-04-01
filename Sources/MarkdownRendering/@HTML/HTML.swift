import HTML

public
enum MarkdownRendering
{

}
extension MarkdownRendering
{
}

@frozen public
enum MarkdownSyntaxHighlight:String, Equatable, Hashable, Sendable
{
    case comment
    case identifier
    case keyword
    case literal
    case magic
    case actor
    case `class`
    case type
    case `typealias`
}

struct MarkdownAttributeContext
{
    private(set)
    var complete:[(name:HTML.Attribute, value:String)]
    var current:(name:MarkdownInstruction.Attribute, utf8:[UInt8])?

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
}
extension MarkdownAttributeContext
{
    private mutating
    func append(attribute instruction:MarkdownInstruction.Attribute, utf8:[UInt8])
    {
        let value:String = .init(decoding: utf8, as: Unicode.UTF8.self)
        switch instruction
        {
        case .language: self.complete.append((.class, "language-\(value)"))

        case .alt:      self.complete.append((.alt, value))
        case .class:    self.complete.append((.class, value))
        case .checked:  self.complete.append((.checked, value))
        case .disabled: self.complete.append((.disabled, value))
        case .href:     self.complete.append((.href, value))
        case .src:      self.complete.append((.src, value))
        case .title:    self.complete.append((.title, value))
        case .type:     self.complete.append((.type, value))
        }
    }
    mutating
    func flush()
    {
        defer
        {
            self.current = nil
        }
        if  let (instruction, utf8):(MarkdownInstruction.Attribute, [UInt8]) = self.current
        {
            self.append(attribute: instruction, utf8: utf8)
        }
    }
    mutating
    func clear()
    {
        self.complete.removeAll()
        self.current = nil
    }
}
extension MarkdownAttributeContext
{
    func encode(to html:inout HTML.AttributeEncoder)
    {
        self.encode(to: &html, highlight: nil)
    }
    func encode(to html:inout HTML.AttributeEncoder, highlight:MarkdownSyntaxHighlight?)
    {
        var classes:[String]

        if  let highlight:MarkdownSyntaxHighlight
        {
            classes = [highlight.rawValue]
        }
        else
        {
            classes = []
        }

        for (name, value):(HTML.Attribute, String) in self.complete
        {
            switch name
            {
            case .class:
                classes.append(value)
            
            default:
                html[name] = value
            }
        }

        html[.class] = classes.joined(separator: " ")
    }
}
extension HTML
{
    private mutating
    func open(_ element:ContainerElement,
        with attributes:MarkdownAttributeContext)
    {
        self.open(element) { attributes.encode(to: &$0) }
    }
    private mutating
    func open(_ highlight:MarkdownSyntaxHighlight,
        with attributes:MarkdownAttributeContext)
    {
        self.open(attributes.contains(.href) ? .a : .span)
        {
            attributes.encode(to: &$0, highlight: highlight)
        }
    }
}
extension HTML
{
    private mutating
    func execute(instruction:MarkdownInstruction.Emit, with attributes:MarkdownAttributeContext)
    {
        let element:HTML.VoidElement

        switch instruction
        {
        case .br:       element = .br
        case .hr:       element = .hr
        case .img:      element = .img
        case .input:    element = .input
        case .wbr:      element = .wbr
        }

        self[element, attributes.encode(to:)]
    }
    private mutating
    func execute(instruction:MarkdownInstruction.Push, with attributes:MarkdownAttributeContext)
    {
        switch instruction
        {
        //  Ignores all attributes!
        case .none:         return
        
        case .a:            self.open(.a,            with: attributes)
        case .blockquote:   self.open(.blockquote,   with: attributes)
        case .code:         self.open(.code,         with: attributes)
        case .em:           self.open(.em,           with: attributes)
        case .li:           self.open(.li,           with: attributes)
        case .h1:           self.open(.h1,           with: attributes)
        case .h2:           self.open(.h2,           with: attributes)
        case .h3:           self.open(.h3,           with: attributes)
        case .h4:           self.open(.h4,           with: attributes)
        case .h5:           self.open(.h5,           with: attributes)
        case .h6:           self.open(.h6,           with: attributes)
        case .ol:           self.open(.ol,           with: attributes)
        case .p:            self.open(.p,            with: attributes)
        case .pre:          self.open(.pre,          with: attributes)
        case .s:            self.open(.s,            with: attributes)
        case .strong:       self.open(.strong,       with: attributes)
        case .table:        self.open(.table,        with: attributes)
        case .tbody:        self.open(.tbody,        with: attributes)
        case .thead:        self.open(.thead,        with: attributes)
        case .td:           self.open(.td,           with: attributes)
        case .th:           self.open(.th,           with: attributes)
        case .tr:           self.open(.tr,           with: attributes)
        case .ul:           self.open(.ul,           with: attributes)

        case .comment:      self.open(.comment,      with: attributes)
        case .identifier:   self.open(.identifier,   with: attributes)
        case .keyword:      self.open(.keyword,      with: attributes)
        case .literal:      self.open(.literal,      with: attributes)
        case .magic:        self.open(.magic,        with: attributes)
        case .actor:        self.open(.actor,        with: attributes)
        case .class:        self.open(.class,        with: attributes)
        case .type:         self.open(.type,         with: attributes)
        case .typealias:    self.open(.typealias,    with: attributes)

        case .parameters:
            self.open(.section, with: attributes)
            self[.h2] = "Parameters"

        case .returns:
            self.open(.section, with: attributes)
            self[.h2] = "Returns"

        case attention
        case author
        case authors
        case bug
        case complexity
        case copyright
        case date
        case experiment
        case important
        case invariant
        case mutating
        case nonmutating
        case note
        case postcondition
        case precondition
        case remark
        case requires
        case seealso
        case since
        case `throws`
        case tip
        case todo
        case version
        case warning
        }
    }

    init(expanding markdown:__shared MarkdownBinary,
        with substitutor:(inout HTML, MarkdownInstruction.Reference) throws -> ()) throws
    {
        self.init()

        var attributes:MarkdownAttributeContext = .init()
        var stack:[MarkdownInstruction.Push] = []

        for instruction:MarkdownInstruction in markdown.bytecode
        {
            switch instruction
            {
            case .invalid:
                throw MarkdownExpansionError.init()
            
            case .attribute(let attribute):
                attributes.flush()
                attributes.current = (attribute, [])
            
            case .emit(let instruction):
                attributes.flush()
                self.execute(instruction: instruction, with: attributes)
                attributes.clear()
            
            case .push(let instruction):
                stack.append(instruction)

                attributes.flush()
                self.execute(instruction: instruction, with: attributes)
                attributes.clear()
            
            case .pop:
                break
            
            case .utf8(let codeunit):
                if  case nil = attributes.current?.utf8.append(codeunit)
                {
                    //  Not in an attribute context.
                    self.utf8.append(codeunit)
                }
            
            case .reference(let reference):
                attributes.clear()
                try substitutor(&self, reference)
            }
        }
    }
}
