import Sources

public
protocol DiagnosticSubject<File>
{
    associatedtype File

    var location:SourceLocation<File>? { get }
    var context:SourceContext { get }
}
