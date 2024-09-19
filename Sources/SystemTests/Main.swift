import System_
import Testing_

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Directories"
        {
            if  let tests:TestGroup = tests / "Exists" / "DoesNotExist"
            {
                tests.do
                {
                    let path:FilePath = "Sources/SystemTests/TheLimit"
                    tests.expect(false: path.directory.exists())
                }
            }
            if  let tests:TestGroup = tests / "Exists" / "DoesExist"
            {
                tests.do
                {
                    let path:FilePath = "Sources/SystemTests/directories/flat"
                    tests.expect(true: path.directory.exists())
                }
            }
            if  let tests:TestGroup = tests / "Exists" / "IsSymlink"
            {
                tests.do
                {
                    let path:FilePath = "Sources/SystemTests/directories/flat-link/a.txt"
                    tests.expect(false: path.directory.exists())
                }
            }
            if  let tests:TestGroup = tests / "Exists" / "IsSymlinkToDirectory"
            {
                tests.do
                {
                    let path:FilePath = "Sources/SystemTests/directories/flat-link"
                    tests.expect(true: path.directory.exists())
                }
            }
            if  let tests:TestGroup = tests / "Exists" / "IsNotDirectory"
            {
                tests.do
                {
                    let path:FilePath = "Sources/SystemTests/directories/flat/a.txt"
                    tests.expect(false: path.directory.exists())
                }
            }
            if  let tests:TestGroup = tests / "Flat"
            {
                let discovered:[FilePath.Component] = tests.do
                {
                    var files:[FilePath] = []

                    let path:FilePath = "Sources/SystemTests/directories/flat"
                    try path.directory.walk
                    {
                        files.append($0)
                        return true
                    }
                    return files.compactMap(\.lastComponent)
                } ?? []

                tests.expect(discovered **? ["a.txt", "b.txt", "c.txt"])
            }

            if  let tests:TestGroup = tests / "Complex"
            {
                let discovered:[FilePath.Component] = tests.do
                {
                    var files:[FilePath] = []

                    let path:FilePath = "Sources/SystemTests/directories/complex"
                    try path.directory.walk
                    {
                        files.append($0)
                        return true
                    }
                    return files.compactMap(\.lastComponent)
                } ?? []

                tests.expect(discovered **?
                    [
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
    }
}
