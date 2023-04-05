import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    enum Block
    {
        case semantic(MarkdownAsidePrefix, [MarkdownTree.Block])
        case regular(MarkdownTree.Block)
    }
}
extension MarkdownDocumentation.Block
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        switch self
        {
        case .regular(let block):
            block.emit(into: &binary)
            return
        
        case .semantic(let type, let elements):
            let context:MarkdownBytecode.Context
            switch type
            {
            case .attention:        context = .attention
            case .author:           context = .author
            case .authors:          context = .authors
            case .bug:              context = .bug
            case .complexity:       context = .complexity
            case .copyright:        context = .copyright
            case .date:             context = .date
            case .experiment:       context = .experiment
            case .important:        context = .important
            case .invariant:        context = .invariant
            case .mutating:         context = .mutating
            case .nonmutating:      context = .nonmutating
            case .note:             context = .note
            case .postcondition:    context = .postcondition
            case .precondition:     context = .precondition
            case .remark:           context = .remark
            case .requires:         context = .requires
            case .returns:          context = .returns
            case .seealso:          context = .seealso
            case .since:            context = .since
            case .throws:           context = .throws
            case .tip:              context = .tip
            case .todo:             context = .todo
            case .version:          context = .version
            case .warning:          context = .warning
            }
            binary[context]
            {
                for block:MarkdownTree.Block in elements
                {
                    block.emit(into: &$0)
                }
            }
        }
    }
}
