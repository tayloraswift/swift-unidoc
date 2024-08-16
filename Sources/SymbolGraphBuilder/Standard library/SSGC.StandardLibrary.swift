import SymbolGraphs

extension SSGC
{
    struct StandardLibrary
    {
        let products:SymbolGraph.Table<SymbolGraph.ProductPlane, SymbolGraph.Product>
        let modules:[SymbolGraph.Module]

        private
        init(products:SymbolGraph.Table<SymbolGraph.ProductPlane, SymbolGraph.Product>,
            modules:[SymbolGraph.Module])
        {
            self.products = products
            self.modules = modules
        }
    }
}
extension SSGC.StandardLibrary
{
    init(platform:SymbolGraphMetadata.Platform)
    {
        switch platform
        {
        case .macOS:    self = .macOS
        case .linux:    self = .linux
        default:        fatalError("Unsupported platform: \(platform)")
        }
    }
}
//  https://forums.swift.org/t/dependency-graph-of-the-standard-library-modules/59267
extension SSGC.StandardLibrary
{
    static var macOS:Self
    {
        .init(
            products: [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 4)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 7)),
            ],
            modules: [
                //  0:
                .toolchain(module: "Swift"),
                //  1:
                .toolchain(module: "_Concurrency",
                    dependencies: 0),
                //  2:
                .toolchain(module: "Distributed",
                    dependencies: 0, 1),

                //  3:
                .toolchain(module: "_StringProcessing",
                    dependencies: 0),
                //  4:
                .toolchain(module: "RegexBuilder",
                    dependencies: 0, 3),

                //  5:
                .toolchain(module: "Dispatch",
                    dependencies: 0),
                //  6:
                .toolchain(module: "DispatchIntrospection",
                    dependencies: 0),
                //  7:
                .toolchain(module: "Foundation",
                    dependencies: 0, 5),
            ])
    }

    static var linux:Self
    {
        .init(
            products: [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 7)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 13)),
            ],
            modules: [
                //  0:
                .toolchain(module: "Swift"),
                //  1:
                .toolchain(module: "_Concurrency",
                    dependencies: 0),
                //  2:
                .toolchain(module: "Distributed",
                    dependencies: 0, 1),

                //  3:
                .toolchain(module: "_Differentiation",
                    dependencies: 0),

                //  4:
                .toolchain(module: "_RegexParser",
                    dependencies: 0),
                //  5:
                .toolchain(module: "_StringProcessing",
                    dependencies: 0, 4),
                //  6:
                .toolchain(module: "RegexBuilder",
                    dependencies: 0, 4, 5),

                //  7:
                .toolchain(module: "Cxx",
                    dependencies: 0),

                //  8:
                .toolchain(module: "Dispatch",
                    dependencies: 0),
                //  9:
                .toolchain(module: "DispatchIntrospection",
                    dependencies: 0),
                // 10:
                .toolchain(module: "Foundation",
                    dependencies: 0, 8),
                // 11:
                .toolchain(module: "FoundationNetworking",
                    dependencies: 0, 8, 10),
                // 12:
                .toolchain(module: "FoundationXML",
                    dependencies: 0, 8, 10),
                // 13:
                .toolchain(module: "XCTest",
                    dependencies: 0),
            ])
    }
}
