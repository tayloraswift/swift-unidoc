#if canImport(Glibc)
import func Glibc.exit
#elseif canImport(Darwin)
import func Darwin.exit
#endif

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public
protocol TestMain
{
    static
    var all:[any TestBattery.Type] { get }
}
extension TestMain where Self:TestBattery
{
    public static
    var all:[any TestBattery.Type] { [Self.self] }
}
extension TestMain
{
    public static
    func main() async throws
    {
        let tests:Tests = try .init()
        for battery:any TestBattery.Type in Self.all
        {
            if  let group:TestGroup = tests / battery.name
            {
                await group.do
                {
                    try await battery.run(tests: group)
                }
            }
        }
        do
        {
            try tests.summarize()
        }
        catch let error as TestFailures
        {
            #if canImport(Glibc) || canImport(Darwin)
            print(error.description)
            exit(1)
            #else
            throw error
            #endif
        }
    }
}
