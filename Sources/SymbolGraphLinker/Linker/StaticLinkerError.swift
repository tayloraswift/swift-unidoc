import UnidocDiagnostics

public
protocol StaticLinkerError:Error
{
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
}
