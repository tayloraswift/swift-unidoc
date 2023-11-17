import SymbolGraphs
import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Availabilities.self,
        Generics.self,
    ]
}
