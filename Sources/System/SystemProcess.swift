#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#else
#error("unsupported platform")
#endif

@frozen public
struct SystemProcess:Identifiable
{
    let invocation:[String]
    public
    let id:pid_t

    private
    init(invocation:[String], id:pid_t)
    {
        self.invocation = invocation
        self.id = id
    }
}
extension SystemProcess
{
    @MainActor public static
    func exit(with status:Int32 = 0) -> Never
    {
        #if canImport(Glibc)
        Glibc.exit(status)
        #elseif canImport(Darwin)
        Darwin.exit(status)
        #else
        fatalError()
        #endif
    }
}
extension SystemProcess
{
    public
    init(command:String?, _ arguments:String?...,
        stdout:FileDescriptor? = nil,
        stderr:FileDescriptor? = nil) throws
    {
        try self.init(command: command, arguments: arguments.compactMap { $0 },
            stdout: stdout,
            stderr: stderr)
    }

    public
    init(command:String?, arguments:[String],
        stdout:FileDescriptor? = nil,
        stderr:FileDescriptor? = nil,
        echo:Bool = false,
        with environment:consuming SystemProcess.Environment = .inherit) throws
    {
        let invocation:[String]
        if  let command:String
        {
            invocation = [command] + arguments
        }
        else
        {
            let current:String = .init(cString: CommandLine.unsafeArgv[0]!)
            invocation = [current] + arguments
        }

        if  echo
        {
            let invocation:String = "\(invocation.joined(separator: " "))\n"
            if  case nil = try stdout?.writeAll(invocation.utf8)
            {
                print(invocation, terminator: "")
            }
        }
        // must be null-terminated!
        let argv:[UnsafeMutablePointer<CChar>?] = invocation.map
        {
            $0.utf8CString.withUnsafeBufferPointer
            {
                let unmanaged:UnsafeMutablePointer<CChar> = .allocate(capacity: $0.count)
                if  let source:UnsafePointer<CChar> = $0.baseAddress
                {
                    unmanaged.initialize(from: source, count: $0.count)
                }
                return unmanaged
            }
        } + [nil]

        defer
        {
            for unmanaged:UnsafeMutablePointer<CChar>? in argv
            {
                unmanaged?.deinitialize(count: 1)
                unmanaged?.deallocate()
            }
        }

        #if canImport(Darwin)
        var actions:posix_spawn_file_actions_t? = nil
        #elseif canImport(Glibc)
        var actions:posix_spawn_file_actions_t = .init()
        #endif

        do
        {
            posix_spawn_file_actions_init(&actions)
        }
        defer
        {
            posix_spawn_file_actions_destroy(&actions)
        }

        if  let stdout:FileDescriptor
        {
            posix_spawn_file_actions_adddup2(&actions, stdout.rawValue, 1)
        }
        if  let stderr:FileDescriptor
        {
            posix_spawn_file_actions_adddup2(&actions, stderr.rawValue, 2)
        }

        var process:pid_t = 0
        let status:Int32 = environment.withUnsafePointers
        {
            if  let command:String
            {
                posix_spawnp(&process, command, &actions, nil, argv, $0)
            }
            else
            {
                posix_spawn(&process, invocation[0], &actions, nil, argv, $0)
            }
        }
        if   status != 0
        {
            throw SystemProcessError.spawn(status, invocation)
        }

        self.init(invocation: invocation, id: process)
    }

    public
    func status() throws -> Int32
    {
        var status:Int32 = 0
        switch waitpid(self.id, &status, 0)
        {
        case self.id:
            return status
        case let status:
            throw SystemProcessError.wait(status, self.invocation)
        }
    }

    public
    func callAsFunction() throws
    {
        switch try self.status()
        {
        case 0:
            return
        case let status:
            throw SystemProcessError.exit(status, self.invocation)
        }
    }
}
