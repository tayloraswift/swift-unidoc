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

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
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
