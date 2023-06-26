import UnidocDiagnostics

public
protocol StaticDiagnosis
{
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
}
