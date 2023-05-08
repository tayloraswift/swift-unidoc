#if os(Linux)
import Glibc
#elseif os(macOS)
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
    public
    init(command:String, _ arguments:String...,
        stdout:FileDescriptor? = nil,
        stderr:FileDescriptor? = nil) throws
    {
        try self.init(command: command, arguments: arguments, stdout: stdout, stderr: stderr)
    }

    public
    init(command:String, arguments:[String],
        stdout:FileDescriptor? = nil,
        stderr:FileDescriptor? = nil) throws
    {
        let invocation:[String] = [command] + arguments
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

        var actions:posix_spawn_file_actions_t = .init()
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

        var pid:pid_t = 0
        switch posix_spawnp(&pid, command, &actions, nil, argv, environ)
        {
        case 0:
            self.init(invocation: invocation, id: pid)
        case let status:
            throw SystemProcessError.spawn(status, invocation)
        }
    }

    public
    func status() async throws -> Int32
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
    func callAsFunction() async throws
    {
        switch try await self.status()
        {
        case 0:
            return
        case let status:
            throw SystemProcessError.exit(status, self.invocation)
        }
    }
}
