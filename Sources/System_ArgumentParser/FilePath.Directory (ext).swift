import ArgumentParser
import System

extension FilePath.Directory:ExpressibleByArgument
{
    @inlinable public
    init?(argument:String) { self.init(argument) }
}
