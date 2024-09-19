import ArgumentParser
import System_

extension FilePath.Directory:ExpressibleByArgument
{
    @inlinable public
    init?(argument:String) { self.init(argument) }
}
