#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#else
#error("unsupported platform")
#endif

@frozen public
struct FileSystemStats:Identifiable, Equatable, Sendable
{
    public
    let id:UInt

    /// Total size of file system in units of ``fragmentSize``.
    public
    let fragmentCount:UInt
    public
    let fragmentSize:UInt

    public
    let blocksFreeForUnprivileged:UInt
    public
    let blocksFree:UInt
    public
    let blockSize:UInt

    public
    let inodesFreeForUnprivileged:UInt
    public
    let inodesFree:UInt
    public
    let inodeCount:UInt

    public
    let maxNameLength:UInt
    public
    let flags:UInt

    @inlinable public
    init(id:UInt,
        fragmentCount:UInt,
        fragmentSize:UInt,
        blocksFreeForUnprivileged:UInt,
        blocksFree:UInt,
        blockSize:UInt,
        inodesFreeForUnprivileged:UInt,
        inodesFree:UInt,
        inodeCount:UInt,
        maxNameLength:UInt,
        flags:UInt)
    {
        self.id = id
        self.fragmentCount = fragmentCount
        self.fragmentSize = fragmentSize
        self.blocksFreeForUnprivileged = blocksFreeForUnprivileged
        self.blocksFree = blocksFree
        self.blockSize = blockSize
        self.inodesFreeForUnprivileged = inodesFreeForUnprivileged
        self.inodesFree = inodesFree
        self.inodeCount = inodeCount
        self.maxNameLength = maxNameLength
        self.flags = flags
    }
}
extension FileSystemStats
{
    public static
    func containing(path:FilePath) throws -> Self
    {
        let stats:statvfs = try withUnsafeTemporaryAllocation(of: statvfs.self, capacity: 1)
        {
            guard case 0 = statvfs(path.string, &$0[0])
            else
            {
                throw Errno.init(rawValue: errno)
            }

            return $0[0]
        }
        //  Explicit `UInt32 -> UInt` conversion needed on Darwin.
        return .init(id: UInt.init(stats.f_fsid),
            fragmentCount: UInt.init(stats.f_blocks),
            fragmentSize: UInt.init(stats.f_frsize),
            blocksFreeForUnprivileged: UInt.init(stats.f_bavail),
            blocksFree: UInt.init(stats.f_bfree),
            blockSize: UInt.init(stats.f_bsize),
            inodesFreeForUnprivileged: UInt.init(stats.f_favail),
            inodesFree: UInt.init(stats.f_ffree),
            inodeCount: UInt.init(stats.f_files),
            maxNameLength: UInt.init(stats.f_namemax),
            flags: UInt.init(stats.f_flag))
    }
}
