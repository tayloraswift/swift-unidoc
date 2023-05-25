import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "directories"
        {
            if  let tests:TestGroup = tests / "flat"
            {
                let discovered:[FilePath.Component] = tests.do
                {
                    var files:[FilePath] = []

                    let path:FilePath = "Tests/System/directories/flat"
                    try path.directory.walk
                    {
                        files.append($0)
                    }
                    return files.compactMap(\.lastComponent)
                } ?? []

                tests.expect(discovered **? ["a.txt", "b.txt", "c.txt"])
            }

            if  let tests:TestGroup = tests / "complex"
            {
                let discovered:[FilePath.Component] = tests.do
                {
                    var files:[FilePath] = []

                    let path:FilePath = "Tests/System/directories/complex"
                    try path.directory.walk
                    {
                        files.append($0)
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
