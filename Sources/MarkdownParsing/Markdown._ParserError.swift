import MarkdownABI
import MarkdownAST
import Sources

extension Markdown
{
    @frozen @usableFromInline
    struct _ParserError:Error
    {
        let subject:SourceReference<Source>
        let problem:any Error

        init(problem:any Error, at subject:SourceReference<Source>)
        {
            self.subject = subject
            self.problem = problem
        }
    }
}
