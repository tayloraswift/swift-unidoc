enum AnyPlugin:~Copyable, Sendable
{
    case a(A)
    case b(B)
    case c(C)

    mutating
    func run() async
    {
        switch consume self
        {
        case .a(var a):
            await a.run()
            self = .a(a)
        case .b(var b):
            await b.run()
            self = .b(b)
        case .c(var c):
            await c.run()
            self = .c(c)
        }
    }
}
extension AnyPlugin
{
    struct A:~Copyable, Sendable
    {
        mutating
        func run() async {}
    }
    struct B:~Copyable, Sendable
    {
        mutating
        func run() async {}
    }
    struct C:~Copyable, Sendable
    {
        mutating
        func run() async {}
    }
}

public
func run(plugins:AnyPlugin...)
{
    await withTaskGroup(of: Void.self)
    {
        for plugin:AnyPlugin in plugins
        {
            $0.addTask
            {
                await plugin.run()
            }
        }
    }
}
