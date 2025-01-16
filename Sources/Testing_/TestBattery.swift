public
protocol TestBattery
{
    static
    var name:String { get }

    static
    func run(tests:TestGroup) async throws
}
extension TestBattery
{
    public static
    var name:String { "\(Self.self)" }
}
