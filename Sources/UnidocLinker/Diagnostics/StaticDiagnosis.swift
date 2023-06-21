import SymbolGraphs

public
protocol StaticDiagnosis
{
    func symbolicated(with symbolicator:Symbolicator) -> [StaticDiagnostic]
}
