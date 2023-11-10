import Sources
import UnidocDiagnostics

extension StaticResolver
{
    struct Autolink
    {
        let quarry:MarkdownSource
        let offset:Range<SourcePosition>?
        let text:String
        let code:Bool

        init(from quarry:MarkdownSource, offset:Range<SourcePosition>?, text:String, code:Bool)
        {
            self.quarry = quarry
            self.offset = offset
            self.text = text
            self.code = code
        }
    }
}
extension StaticResolver.Autolink:DiagnosticSubject
{
    var location:SourceLocation<Int32>?
    {
        if  let base:SourceLocation<Int32> = self.quarry.location,
            let offset:Range<SourcePosition> = self.offset
        {
            return base.translated(by: offset.lowerBound)
        }
        else
        {
            return nil
        }
    }

    var context:SourceContext
    {
        self.offset.map { self.quarry[$0] } ?? []
    }
}
