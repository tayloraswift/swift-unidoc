import SourceDiagnostics

extension SSGC
{
    enum ResourceError:Error
    {
        case fileRequired(argument:String)
        case fileNotFound(String)
    }
}
extension SSGC.ResourceError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output:inout DiagnosticOutput<Symbolicator>)
    {
        switch self
        {
        case .fileRequired(argument: let label):
            output[.error] = "no file name specified"
            output[.note] = "specify a resource with '\(label):'"

        case .fileNotFound(let file):
            output[.error] = "file not found (\(file))"
        }
    }
}
