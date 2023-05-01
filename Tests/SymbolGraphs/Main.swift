import SymbolGraphs
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        TestAvailability(tests / "availability")
    }
}
