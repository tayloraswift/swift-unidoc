import MarkdownABI
import MarkdownTrees

@frozen public
enum MarkdownKeywordPrefix:String, Equatable, Hashable, Sendable
{
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
    case mutating = "mutatingvariant"
    case nonmutating = "nonmutatingvariant"
    case note
    case parameters
    case postcondition
    case precondition
    case remark
    case requires
    case returns
    case seealso
    case since
    case `throws`
    case tip
    case todo
    case version
    case warning
}
extension MarkdownKeywordPrefix
{
    func callAsFunction(_ discussion:__owned [MarkdownBlock]) -> MarkdownBlock
    {
        switch self
        {
        case .attention:        return MarkdownBlock.Aside.Attention.init(discussion)
        case .author:           return MarkdownBlock.Aside.Author.init(discussion)
        case .authors:          return MarkdownBlock.Aside.Authors.init(discussion)
        case .bug:              return MarkdownBlock.Aside.Bug.init(discussion)
        case .complexity:       return MarkdownBlock.Aside.Complexity.init(discussion)
        case .copyright:        return MarkdownBlock.Aside.Copyright.init(discussion)
        case .date:             return MarkdownBlock.Aside.Date.init(discussion)
        case .experiment:       return MarkdownBlock.Aside.Experiment.init(discussion)
        case .important:        return MarkdownBlock.Aside.Important.init(discussion)
        case .invariant:        return MarkdownBlock.Aside.Invariant.init(discussion)
        case .mutating:         return MarkdownBlock.Aside.Mutating.init(discussion)
        case .nonmutating:      return MarkdownBlock.Aside.Nonmutating.init(discussion)
        case .note:             return MarkdownBlock.Aside.Note.init(discussion)
        case .parameters:       return MarkdownBlock.Parameters.init(discussion)
        case .postcondition:    return MarkdownBlock.Aside.Postcondition.init(discussion)
        case .precondition:     return MarkdownBlock.Aside.Precondition.init(discussion)
        case .remark:           return MarkdownBlock.Aside.Remark.init(discussion)
        case .requires:         return MarkdownBlock.Aside.Requires.init(discussion)
        case .returns:          return MarkdownBlock.Aside.Returns.init(discussion)
        case .seealso:          return MarkdownBlock.Aside.SeeAlso.init(discussion)
        case .since:            return MarkdownBlock.Aside.Since.init(discussion)
        case .throws:           return MarkdownBlock.Aside.Throws.init(discussion)
        case .tip:              return MarkdownBlock.Aside.Tip.init(discussion)
        case .todo:             return MarkdownBlock.Aside.ToDo.init(discussion)
        case .version:          return MarkdownBlock.Aside.Version.init(discussion)
        case .warning:          return MarkdownBlock.Aside.Warning.init(discussion)
        }
    }
}
extension MarkdownKeywordPrefix:MarkdownSemanticPrefix
{
    /// If a keyword pattern uses formatting, the formatting must apply
    /// to the entire pattern.
    static
    var radius:Int { 2 }

    init?(from elements:__shared [MarkdownInline.Block])
    {
        if  elements.count == 1
        {
            self.init(elements[0].text)
        }
        else
        {
            return nil
        }
    }

    private
    init?(_ description:String)
    {
        var lowercased:String = ""
            lowercased.reserveCapacity(description.utf8.count)
        var words:Int = 0
        for character:Character in description
        {
            if      character.isLetter
            {
                lowercased.append(character.lowercased())
            }
            //  Limit to 3 words, because the ``nonmutating`` keyphrase
            //  can be written as 'Non-mutating variant'.
            else if character == " " ||
                    character == "-",
                    words < 3
            {
                words += 1
                continue
            }
            else
            {
                return nil
            }
        }
        self.init(rawValue: lowercased)
    }
}
