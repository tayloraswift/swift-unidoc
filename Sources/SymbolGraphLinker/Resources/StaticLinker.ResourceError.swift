import SourceDiagnostics

extension StaticLinker
{
    enum ResourceError:Error
    {
        case fileRequired(argument:String)
        case fileNotFound(String)
    }
}
extension StaticLinker.ResourceError:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        switch self
        {
        case .fileRequired(argument: let label):
            output[.warning] = "no file name specified"
            output[.note] = "specify a resource with '\(label):'"

        case .fileNotFound(let file):
            output[.error] = "file not found (\(file))"
        }
    }
}
