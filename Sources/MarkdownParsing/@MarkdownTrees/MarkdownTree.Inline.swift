import Markdown
import MarkdownTrees

extension MarkdownTree.Inline:ParsableAsInlineMarkup
{
    init(from markup:any InlineMarkup)
    {
        switch markup
        {
        case is LineBreak:
            self = .text("\n")
        
        case is SoftBreak:
            self = .text(" ")
        
        case let span as CustomInline: 
            self = .text(span.text)
        
        case let span as Text:
            self = .text(span.string)
        
        case let span as InlineHTML:
            self = .html(.init(text: span.rawHTML))
        
        case let span as InlineCode:
            self = .code(.init(text: span.code))
        
        case let span as Emphasis:
            self = .container(.init(from: span, as: .em))
        
        case let span as Strikethrough:
            self = .container(.init(from: span, as: .s))
        
        case let span as Strong:
            self = .container(.init(from: span, as: .strong))
            
        case let unsupported: 
            self = .code(.init(text: "<unsupported markdown node '\(type(of: unsupported))'>"))
        }
    }
}
