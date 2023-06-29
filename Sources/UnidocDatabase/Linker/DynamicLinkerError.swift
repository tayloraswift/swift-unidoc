import UnidocDiagnostics

protocol DynamicLinkerError:Error
{
    func symbolicated(with symbolicator:DynamicSymbolicator) -> [Diagnostic]
}
