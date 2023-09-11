import JSONAST

extension JSON.ArrayEncoder
{
    @frozen public
    enum Index
    {
    }
}
extension JSON.ArrayEncoder.Index
{
    @inlinable public static prefix
    func + (_:Self)
    {
    }
}
