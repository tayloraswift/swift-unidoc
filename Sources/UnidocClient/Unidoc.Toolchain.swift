import SymbolGraphBuilder
import SystemIO

extension Unidoc
{
    @frozen public
    struct Toolchain:Equatable, Sendable
    {
        public
        let usr:FilePath.Directory?
        public
        let sdk:SSGC.AppleSDK?

        @inlinable public
        init(usr:FilePath.Directory?, sdk:SSGC.AppleSDK? = nil)
        {
            self.usr = usr
            self.sdk = sdk
        }
    }
}
