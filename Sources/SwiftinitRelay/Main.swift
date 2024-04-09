import ArgumentParsing
import NIOCore
import NIOPosix

@main
struct Main
{
    private
    var gateways:[Gateway]

    init()
    {
        self.gateways = []
    }

    public static
    func main() async throws
    {
        var main:Self = .init()
        try main.parse()
        try await main.launch()
    }
}
extension Main
{
    private mutating
    func parse() throws
    {
        var arguments:CommandLine.Arguments = .init()
        while let next:String = arguments.next()
        {
            guard
            let gateway:Gateway = .init(next)
            else
            {
                throw Gateway.ParsingError.invalid(next)
            }

            self.gateways.append(gateway)
        }
    }

    private consuming
    func launch() async throws
    {
        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
            for gateway:Gateway in self.gateways
            {
                tasks.addTask
                {
                    try await gateway.listen(on: executor)
                }
            }

            defer
            {
                tasks.cancelAll()
            }

            for try await _:Void in tasks
            {
                break
            }
        }
    }
}
