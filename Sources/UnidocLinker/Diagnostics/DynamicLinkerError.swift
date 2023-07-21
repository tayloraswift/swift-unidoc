import UnidocDiagnostics

public
protocol DynamicLinkerError:Error
{
    func symbolicated(with symbolicator:DynamicSymbolicator) -> [Diagnostic]
}
