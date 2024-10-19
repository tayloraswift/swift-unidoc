import ArgumentParser
import System_

extension FilePath:@retroactive ExpressibleByArgument
{
    @inlinable public
    init?(argument:String) { self.init(argument) }
}
