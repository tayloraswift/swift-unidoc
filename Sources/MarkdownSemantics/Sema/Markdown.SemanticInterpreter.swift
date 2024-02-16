import SourceDiagnostics

extension Markdown
{
    typealias SemanticInterpreter = _MarkdownSemanticInterpreter
}
protocol _MarkdownSemanticInterpreter<Symbolicator>
{
    associatedtype Symbolicator:DiagnosticSymbolicator<Int32>

    init(diagnostics:consuming Diagnostics<Symbolicator>)
    var diagnostics:Diagnostics<Symbolicator> { consuming get }

    // mutating
    // func record(error:any Error, in block:Markdown.BlockElement)
    mutating
    func append(_ block:Markdown.BlockElement)
}
