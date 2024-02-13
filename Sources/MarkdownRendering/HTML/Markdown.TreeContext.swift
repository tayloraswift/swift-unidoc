import HTML
import MarkdownABI

extension Markdown
{
    enum TreeContext
    {
        /// An anchorable context, which generates an HTML container element
        /// with an `a` element inside of it that links to the outer container’s
        /// fragment `id`.
        case anchorable(HTML.ContainerElement)
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
        /// A snippet context, which generates a `pre` element with a `code`
        /// element inside of it, and enables line numbers. The outer `pre`
        /// element has a single class named `snippet`.
        case snippet
        /// The transparent context, which ignores attributes, and renders
        /// all nested elements without any wrappers, and without escaping
        /// special characters.
        case transparent
    }
}
extension Markdown.TreeContext
{
    private static
    func heading(_ type:HTML.ContainerElement, attributes:borrowing AttributeList) -> Self
    {
        attributes.id == nil ? .container(type) : .anchorable(type)
    }

    private static
    func highlight(_ type:Markdown.SyntaxHighlight, attributes:inout AttributeList) -> Self
    {
        let container:HTML.ContainerElement = attributes.href == nil ? .span : .a
        attributes.append(class: type)
        return .highlight(.init(container: container, type: type))
    }

    private static
    func section(_ type:Section, attributes:inout AttributeList) -> Self
    {
        attributes.append(class: type)
        return .section(type)
    }
    private static
    func signage(_ type:Signage, attributes:inout AttributeList) -> Self
    {
        attributes.append(class: type)
        return .signage(type)
    }
}
extension Markdown.TreeContext
{
    init(from markdown:Markdown.Bytecode.Context, attributes:inout AttributeList)
    {
        switch markdown
        {
        case .transparent:      self = .transparent

        case .a:                self = .container(.a)
        case .blockquote:       self = .container(.blockquote)
        case .code:             self = .container(.code)
        case .dd:               self = .container(.dd)
        case .dl:               self = .container(.dl)
        case .dt:               self = .heading(.dt,                attributes: attributes)
        case .em:               self = .container(.em)
        case .li:               self = .container(.li)
        case .h1:               self = .heading(.h1,                attributes: attributes)
        case .h2:               self = .heading(.h2,                attributes: attributes)
        case .h3:               self = .heading(.h3,                attributes: attributes)
        case .h4:               self = .heading(.h4,                attributes: attributes)
        case .h5:               self = .heading(.h5,                attributes: attributes)
        case .h6:               self = .heading(.h6,                attributes: attributes)
        case .ol:               self = .container(.ol)
        case .p:                self = .container(.p)
        case .pre:              self = .container(.pre)
        case .s:                self = .container(.s)
        case .strong:           self = .container(.strong)
        case .table:            self = .container(.table)
        case .tbody:            self = .container(.tbody)
        case .thead:            self = .container(.thead)
        case .td:               self = .container(.td)
        case .th:               self = .container(.th)
        case .tr:               self = .container(.tr)
        case .ul:               self = .container(.ul)

        case .html:             self = .container(.html)
        case .head:             self = .container(.head)
        case .body:             self = .container(.body)
        case .abbr:             self = .container(.abbr)
        case .audio:            self = .container(.audio)
        case .b:                self = .container(.b)
        case .bdi:              self = .container(.bdi)
        case .bdo:              self = .container(.bdo)
        case .address:          self = .container(.address)
        case .article:          self = .container(.article)
        case .aside:            self = .container(.aside)
        case .button:           self = .container(.button)
        case .canvas:           self = .container(.canvas)
        case .caption:          self = .container(.caption)
        case .colgroup:         self = .container(.colgroup)
        case .cite:             self = .container(.cite)
        case .data:             self = .container(.data)
        case .datalist:         self = .container(.datalist)
        case .del:              self = .container(.del)
        case .details:          self = .container(.details)
        case .dialog:           self = .container(.dialog)
        case .dfn:              self = .container(.dfn)
        case .div:              self = .container(.div)
        case .embed:            self = .container(.embed)
        case .fieldset:         self = .container(.fieldset)
        case .figcaption:       self = .container(.figcaption)
        case .figure:           self = .container(.figure)
        case .footer:           self = .container(.footer)
        case .form:             self = .container(.form)
        case .header:           self = .container(.header)
        case .i:                self = .container(.i)
        case .iframe:           self = .container(.iframe)
        case .ins:              self = .container(.ins)
        case .kbd:              self = .container(.kbd)
        case .label:            self = .container(.label)
        case .legend:           self = .container(.legend)
        case .main:             self = .container(.main)
        case .map:              self = .container(.map)
        case .mark:             self = .container(.mark)
        case .menu:             self = .container(.menu)
        case .meter:            self = .container(.meter)
        case .nav:              self = .container(.nav)
        case .noscript:         self = .container(.noscript)
        case .object:           self = .container(.object)
        case .optgroup:         self = .container(.optgroup)
        case .option:           self = .container(.option)
        case .output:           self = .container(.output)
        case .picture:          self = .container(.picture)
        case .portal:           self = .container(.portal)
        case .progress:         self = .container(.progress)
        case .q:                self = .container(.q)
        case .rp:               self = .container(.rp)
        case .rt:               self = .container(.rt)
        case .ruby:             self = .container(.ruby)
        case .samp:             self = .container(.samp)
        case .small:            self = .container(.small)
        case .section:          self = .container(.section)
        case .span:             self = .container(.span)
        case .select:           self = .container(.select)
        case .slot:             self = .container(.slot)
        case .sub:              self = .container(.sub)
        case .summary:          self = .container(.summary)
        case .sup:              self = .container(.sup)
        case .template:         self = .container(.template)
        case .textarea:         self = .container(.textarea)
        case .tfoot:            self = .container(.tfoot)
        case .time:             self = .container(.time)
        case .title:            self = .container(.title)
        case .u:                self = .container(.u)
        case .var:              self = .container(.var)
        case .video:            self = .container(.video)

        case .snippet:          self = .snippet

        case .attribute:        self = .highlight(.attribute,       attributes: &attributes)
        case .binding:          self = .highlight(.binding,         attributes: &attributes)
        case .comment:          self = .highlight(.comment,         attributes: &attributes)
        case .directive:        self = .highlight(.directive,       attributes: &attributes)
        case .doccomment:       self = .highlight(.doccomment,      attributes: &attributes)
        case .identifier:       self = .highlight(.identifier,      attributes: &attributes)
        case .interpolation:    self = .highlight(.interpolation,   attributes: &attributes)
        case .keyword:          self = .highlight(.keyword,         attributes: &attributes)
        case .literalNumber:    self = .highlight(.literalNumber,   attributes: &attributes)
        case .literalString:    self = .highlight(.literalString,   attributes: &attributes)
        case .magic:            self = .highlight(.magic,           attributes: &attributes)
        case .operator:         self = .highlight(.operator,        attributes: &attributes)
        case .pseudo:           self = .highlight(.pseudo,          attributes: &attributes)
        case .actor:            self = .highlight(.actor,           attributes: &attributes)
        case .class:            self = .highlight(.class,           attributes: &attributes)
        case .type:             self = .highlight(.type,            attributes: &attributes)
        case .typealias:        self = .highlight(.typealias,       attributes: &attributes)
        case .indent:           self = .highlight(.indent,          attributes: &attributes)

        case .parameters:       self = .section(.parameters,        attributes: &attributes)
        case .returns:          self = .section(.returns,           attributes: &attributes)
        case .throws:           self = .section(.throws,            attributes: &attributes)

        case .attention:        self = .signage(.attention,         attributes: &attributes)
        case .author:           self = .signage(.author,            attributes: &attributes)
        case .authors:          self = .signage(.authors,           attributes: &attributes)
        case .bug:              self = .signage(.bug,               attributes: &attributes)
        case .complexity:       self = .signage(.complexity,        attributes: &attributes)
        case .copyright:        self = .signage(.copyright,         attributes: &attributes)
        case .date:             self = .signage(.date,              attributes: &attributes)
        case .experiment:       self = .signage(.experiment,        attributes: &attributes)
        case .important:        self = .signage(.important,         attributes: &attributes)
        case .invariant:        self = .signage(.invariant,         attributes: &attributes)
        case .mutating:         self = .signage(.mutating,          attributes: &attributes)
        case .nonmutating:      self = .signage(.nonmutating,       attributes: &attributes)
        case .note:             self = .signage(.note,              attributes: &attributes)
        case .postcondition:    self = .signage(.postcondition,     attributes: &attributes)
        case .precondition:     self = .signage(.precondition,      attributes: &attributes)
        case .remark:           self = .signage(.remark,            attributes: &attributes)
        case .requires:         self = .signage(.requires,          attributes: &attributes)
        case .seealso:          self = .signage(.seealso,           attributes: &attributes)
        case .since:            self = .signage(.since,             attributes: &attributes)
        case .tip:              self = .signage(.tip,               attributes: &attributes)
        case .todo:             self = .signage(.todo,              attributes: &attributes)
        case .version:          self = .signage(.version,           attributes: &attributes)
        case .warning:          self = .signage(.warning,           attributes: &attributes)
        }
    }
}
