import ArgumentParser
import System

extension FilePath:ExpressibleByArgument
{
    @inlinable public
    init?(argument:String) { self.init(argument) }
}
