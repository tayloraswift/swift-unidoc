import ArgumentParser

extension Regex<Substring>:@retroactive ExpressibleByArgument, @retroactive _SendableMetatype
{
    @inlinable public
    init?(argument:String)
    {
        do
        {
            try self.init(argument)
        }
        catch
        {
            return nil
        }
    }
}
