import MarkdownABI
import MarkdownAST

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
        case .attention:        MarkdownBlock.Aside.Attention.init(discussion)
        case .author:           MarkdownBlock.Aside.Author.init(discussion)
        case .authors:          MarkdownBlock.Aside.Authors.init(discussion)
        case .bug:              MarkdownBlock.Aside.Bug.init(discussion)
        case .complexity:       MarkdownBlock.Aside.Complexity.init(discussion)
        case .copyright:        MarkdownBlock.Aside.Copyright.init(discussion)
        case .date:             MarkdownBlock.Aside.Date.init(discussion)
        case .experiment:       MarkdownBlock.Aside.Experiment.init(discussion)
        case .important:        MarkdownBlock.Aside.Important.init(discussion)
        case .invariant:        MarkdownBlock.Aside.Invariant.init(discussion)
        case .mutating:         MarkdownBlock.Aside.Mutating.init(discussion)
        case .nonmutating:      MarkdownBlock.Aside.Nonmutating.init(discussion)
        case .note:             MarkdownBlock.Aside.Note.init(discussion)
        case .parameters:       MarkdownBlock.Parameters.init(discussion)
        case .postcondition:    MarkdownBlock.Aside.Postcondition.init(discussion)
        case .precondition:     MarkdownBlock.Aside.Precondition.init(discussion)
        case .remark:           MarkdownBlock.Aside.Remark.init(discussion)
        case .requires:         MarkdownBlock.Aside.Requires.init(discussion)
        case .returns:          MarkdownBlock.Aside.Returns.init(discussion)
        case .seealso:          MarkdownBlock.Aside.SeeAlso.init(discussion)
        case .since:            MarkdownBlock.Aside.Since.init(discussion)
        case .throws:           MarkdownBlock.Aside.Throws.init(discussion)
        case .tip:              MarkdownBlock.Aside.Tip.init(discussion)
        case .todo:             MarkdownBlock.Aside.ToDo.init(discussion)
        case .version:          MarkdownBlock.Aside.Version.init(discussion)
        case .warning:          MarkdownBlock.Aside.Warning.init(discussion)
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
