import ArgumentParser
import System_ArgumentParser
import SystemIO

extension Unidoc
{
    public
    struct ListAssetsCommand:ParsableCommand
    {
        public
        static let configuration:CommandConfiguration = .init(commandName: "list-assets")

        @Argument
        var pattern:Regex<Substring>?

        @Option(name: [.customLong("assets-directory"), .customShort("p")])
        var assets:FilePath = "Assets"

        @Flag(name: [.customLong("long"), .customShort("l")])
        var long:Bool = false

        @Flag(name: [.customLong("include-nonfree"), .customShort("a")])
        var includeNonfree:Bool = false

        public
        init() {}

        public
        func run() throws
        {
            for asset:Unidoc.Asset in Unidoc.Asset.allCases
            {
                guard self.includeNonfree || asset.libre
                else
                {
                    continue
                }

                if  let pattern:Regex<Substring> = self.pattern,
                    case nil = try pattern.wholeMatch(in: "\(asset)")
                {
                    continue
                }

                let path:FilePath = self.assets.appending(asset.source)

                print(self.long ? """
                    \(path)\t\
                    \(asset.path(prepending: Unidoc.RenderFormat.Assets.version))\t\
                    \(asset.type)
                    """ : """
                    \(path)
                    """)
            }
        }
    }
}
