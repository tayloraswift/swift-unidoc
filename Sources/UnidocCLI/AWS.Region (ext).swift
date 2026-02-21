import ArgumentParser
import S3

extension AWS.Region: ExpressibleByArgument {
    @inlinable public init?(argument: String) { self.init(argument) }
}
