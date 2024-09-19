import ArgumentParser
import System_

extension FilePath:ExpressibleByArgument
{
    @inlinable public
    init?(argument:String) { self.init(argument) }
}
