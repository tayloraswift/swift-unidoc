/// A pathetic imitation of
/// https://github.com/apple/swift-driver/blob/main/Sources/SwiftDriver/Utilities/Triple.swift
@frozen public
struct Triple:Equatable, Hashable, Sendable
{
    //  Almost every component can fit in inline ``String`` storage, so we
    //  store components of ``String`` and not ``Substring``.
    public
    let arch:String
    public
    let vendor:String
    public
    let os:String
    public
    let environment:String?

    @inlinable public
    init(_ arch:String, _ vendor:String, _ os:String, _ environment:String? = nil)
    {
        self.arch = arch
        self.vendor = vendor
        self.os = os
        self.environment = environment
    }
}
extension Triple:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.environment.map
        {
            "\(self.arch)-\(self.vendor)-\(self.os)-\($0)"
        } ?? "\(self.arch)-\(self.vendor)-\(self.os)"
    }
}
extension Triple:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(description[...])
    }
    @inlinable public
    init?(_ description:Substring)
    {
        let components:[Substring] = description.split(separator: "-", maxSplits: 3)
        switch components.count
        {
        case 4:
            self.init(
                .init(components[0]),
                .init(components[1]),
                .init(components[2]),
                .init(components[3]))
        case 3:
            self.init(
                .init(components[0]),
                .init(components[1]),
                .init(components[2]))
        case _:
            return nil
        }
    }
}
