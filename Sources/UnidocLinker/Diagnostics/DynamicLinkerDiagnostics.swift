/// Adds a layer of indirection to diagnostic collection. This allows linker operations that
/// only change linker state by emitting diagnostics to be non-mutating.
final
class DynamicLinkerDiagnostics
{
    var errors:[any DynamicLinkerError]

    init(_ errors:[any DynamicLinkerError] = [])
    {
        self.errors = errors
    }
}
