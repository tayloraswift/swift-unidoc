import UnidocDiagnostics

protocol DynamicDiagnosis
{
    func symbolicated(with symbolicator:DynamicSymbolicator) -> [Diagnostic]
}
