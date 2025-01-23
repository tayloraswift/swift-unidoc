import System_
import Testing

@Suite
enum Directories
{
    @Test
    static func ExistenceDoesNotExist() throws
    {
        let path:FilePath = "Sources/SystemTests/TheLimit"
        #expect(!path.directory.exists())
    }
    @Test
    static func ExistenceDoesExist() throws
    {
        let path:FilePath = "Sources/SystemTests/directories/flat"
        #expect(path.directory.exists())
    }
    @Test
    static func ExistenceIsSymlink() throws
    {
        let path:FilePath = "Sources/SystemTests/directories/flat-link/a.txt"
        #expect(!path.directory.exists())
    }
    @Test
    static func ExistenceIsSymlinkToDirectory() throws
    {
        let path:FilePath = "Sources/SystemTests/directories/flat-link"
        #expect(path.directory.exists())
    }
    @Test
    static func ExistenceIsNotDirectory() throws
    {
        let path:FilePath = "Sources/SystemTests/directories/flat/a.txt"
        #expect(!path.directory.exists())
    }
    @Test
    static func Flat() throws
    {
        var files:[FilePath] = []

        let path:FilePath = "Sources/SystemTests/directories/flat"
        try path.directory.walk
        {
            files.append($0)
            return true
        }
        let discovered:Set<FilePath.Component> = files.reduce(into: [])
        {
            if  let file:FilePath.Component = $1.lastComponent
            {
                $0.insert(file)
            }
        }

        #expect(discovered == ["a.txt", "b.txt", "c.txt"])
    }

    @Test
    static func Complex() throws
    {
        var files:[FilePath] = []

        let path:FilePath = "Sources/SystemTests/directories/complex"
        try path.directory.walk
        {
            files.append($0)
            return true
        }

        let discovered:Set<FilePath.Component> = files.reduce(into: [])
        {
            if  let file:FilePath.Component = $1.lastComponent
            {
                $0.insert(file)
            }
        }

        #expect(discovered == [
                "a.txt",
                "b.txt",
                "x",
                    "c.txt",
                    "y",
                        "d.txt",
                    "z",
                        "e.txt"
            ])
    }
}
