import MarkdownABI
import MarkdownAST

extension Markdown {
    @frozen public enum KeywordPrefix: String, Equatable, Hashable, Sendable {
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
}
extension Markdown.KeywordPrefix {
    func callAsFunction(
        _ discussion: __owned [Markdown.BlockElement]
    ) -> Markdown.BlockElement {
        switch self {
        case .attention:        Markdown.BlockAside.Attention.init(discussion)
        case .author:           Markdown.BlockAside.Author.init(discussion)
        case .authors:          Markdown.BlockAside.Authors.init(discussion)
        case .bug:              Markdown.BlockAside.Bug.init(discussion)
        case .complexity:       Markdown.BlockAside.Complexity.init(discussion)
        case .copyright:        Markdown.BlockAside.Copyright.init(discussion)
        case .date:             Markdown.BlockAside.Date.init(discussion)
        case .experiment:       Markdown.BlockAside.Experiment.init(discussion)
        case .important:        Markdown.BlockAside.Important.init(discussion)
        case .invariant:        Markdown.BlockAside.Invariant.init(discussion)
        case .mutating:         Markdown.BlockAside.Mutating.init(discussion)
        case .nonmutating:      Markdown.BlockAside.Nonmutating.init(discussion)
        case .note:             Markdown.BlockAside.Note.init(discussion)
        case .parameters:       Markdown.BlockParameters.init(discussion)
        case .postcondition:    Markdown.BlockAside.Postcondition.init(discussion)
        case .precondition:     Markdown.BlockAside.Precondition.init(discussion)
        case .remark:           Markdown.BlockAside.Remark.init(discussion)
        case .requires:         Markdown.BlockAside.Requires.init(discussion)
        case .returns:          Markdown.BlockAside.Returns.init(discussion)
        case .seealso:          Markdown.BlockAside.SeeAlso.init(discussion)
        case .since:            Markdown.BlockAside.Since.init(discussion)
        case .throws:           Markdown.BlockAside.Throws.init(discussion)
        case .tip:              Markdown.BlockAside.Tip.init(discussion)
        case .todo:             Markdown.BlockAside.ToDo.init(discussion)
        case .version:          Markdown.BlockAside.Version.init(discussion)
        case .warning:          Markdown.BlockAside.Warning.init(discussion)
        }
    }
}
extension Markdown.KeywordPrefix: Markdown.SemanticPrefix {
    /// If a keyword pattern uses formatting, the formatting must apply
    /// to the entire pattern.
    static var radius: Int { 2 }

    init?(from elements: __shared [Markdown.InlineElement]) {
        if  elements.count == 1 {
            self.init(elements[0].text)
        } else {
            return nil
        }
    }

    private init?(_ description: String) {
        var lowercased: String = ""
        lowercased.reserveCapacity(description.utf8.count)
        var words: Int = 0
        for character: Character in description {
            if      character.isLetter {
                lowercased.append(character.lowercased())
            }
            //  Limit to 3 words, because the ``nonmutating`` keyphrase
            //  can be written as 'Non-mutating variant'.
            else if character == " " ||
                character == "-",
                words < 3 {
                words += 1
                continue
            } else {
                return nil
            }
        }
        self.init(rawValue: lowercased)
    }
}
