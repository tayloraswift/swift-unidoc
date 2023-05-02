import HTML
import MarkdownABI

enum MarkdownElementContext
{
    /// A normal HTML container element.
    case container(HTML.ContainerElement)
    /// A syntax highlight, which generates an `a` or `span` element,
    /// depending on its attribute context.
    case highlight(Highlight)
    /// A section context, which generates a `section` element, with
    /// a synthesized `h2` heading.
    case section(Section)
    /// A signage context, which generates an `aside` element, with
    /// a synthesized `h3` heading.
    case signage(Signage)
    /// The transparent context, which ignores attributes, and renders
    /// all nested elements without any wrappers, and without escaping
    /// special characters.
    case transparent
}
extension MarkdownElementContext
{
    private static
    func highlight(_ type:MarkdownSyntaxHighlight,
        attributes:inout MarkdownAttributeContext) -> Self
    {
        let container:HTML.ContainerElement = attributes.contains(.href) ? .a : .span
        attributes.append(class: type)
        return .highlight(.init(container: container, type: type))
    }

    private static
    func section(_ type:Section, attributes:inout MarkdownAttributeContext) -> Self
    {
        attributes.append(class: type)
        return .section(type)
    }
    private static
    func signage(_ type:Signage, attributes:inout MarkdownAttributeContext) -> Self
    {
        attributes.append(class: type)
        return .signage(type)
    }
}
extension MarkdownElementContext
{
    init(from markdown:MarkdownBytecode.Context, attributes:inout MarkdownAttributeContext)
    {
        switch markdown
        {
        case .transparent:  self = .transparent
        
        case .a:            self = .container(.a)
        case .blockquote:   self = .container(.blockquote)
        case .code:         self = .container(.code)
        case .dd:           self = .container(.dd)
        case .dl:           self = .container(.dl)
        case .dt:           self = .container(.dt)
        case .em:           self = .container(.em)
        case .li:           self = .container(.li)
        case .h1:           self = .container(.h1)
        case .h2:           self = .container(.h2)
        case .h3:           self = .container(.h3)
        case .h4:           self = .container(.h4)
        case .h5:           self = .container(.h5)
        case .h6:           self = .container(.h6)
        case .ol:           self = .container(.ol)
        case .p:            self = .container(.p)
        case .pre:          self = .container(.pre)
        case .s:            self = .container(.s)
        case .strong:       self = .container(.strong)
        case .table:        self = .container(.table)
        case .tbody:        self = .container(.tbody)
        case .thead:        self = .container(.thead)
        case .td:           self = .container(.td)
        case .th:           self = .container(.th)
        case .tr:           self = .container(.tr)
        case .ul:           self = .container(.ul)

        case .attribute:    self = .highlight(.keyword,     attributes: &attributes)
        case .binding:      self = .highlight(.binding,     attributes: &attributes)
        case .comment:      self = .highlight(.comment,     attributes: &attributes)
        case .identifier:   self = .highlight(.identifier,  attributes: &attributes)
        case .interpolation:self = .highlight(.magic,       attributes: &attributes)
        case .keyword:      self = .highlight(.keyword,     attributes: &attributes)
        case .literal:      self = .highlight(.literal,     attributes: &attributes)
        case .magic:        self = .highlight(.magic,       attributes: &attributes)
        case .actor:        self = .highlight(.actor,       attributes: &attributes)
        case .class:        self = .highlight(.class,       attributes: &attributes)
        case .type:         self = .highlight(.type,        attributes: &attributes)
        case .typealias:    self = .highlight(.typealias,   attributes: &attributes)

        case .parameters:   self = .section(.parameters,    attributes: &attributes)
        case .returns:      self = .section(.returns,       attributes: &attributes)
        case .throws:       self = .section(.throws,        attributes: &attributes)

        case .attention:    self = .signage(.attention,     attributes: &attributes)
        case .author:       self = .signage(.author,        attributes: &attributes)
        case .authors:      self = .signage(.authors,       attributes: &attributes)
        case .bug:          self = .signage(.bug,           attributes: &attributes)
        case .complexity:   self = .signage(.complexity,    attributes: &attributes)
        case .copyright:    self = .signage(.copyright,     attributes: &attributes)
        case .date:         self = .signage(.date,          attributes: &attributes)
        case .experiment:   self = .signage(.experiment,    attributes: &attributes)
        case .important:    self = .signage(.important,     attributes: &attributes)
        case .invariant:    self = .signage(.invariant,     attributes: &attributes)
        case .mutating:     self = .signage(.mutating,      attributes: &attributes)
        case .nonmutating:  self = .signage(.nonmutating,   attributes: &attributes)
        case .note:         self = .signage(.note,          attributes: &attributes)
        case .postcondition:self = .signage(.postcondition, attributes: &attributes)
        case .precondition: self = .signage(.precondition,  attributes: &attributes)
        case .remark:       self = .signage(.remark,        attributes: &attributes)
        case .requires:     self = .signage(.requires,      attributes: &attributes)
        case .seealso:      self = .signage(.seealso,       attributes: &attributes)
        case .since:        self = .signage(.since,         attributes: &attributes)
        case .tip:          self = .signage(.tip,           attributes: &attributes)
        case .todo:         self = .signage(.todo,          attributes: &attributes)
        case .version:      self = .signage(.version,       attributes: &attributes)
        case .warning:      self = .signage(.warning,       attributes: &attributes)
        }
    }
}
