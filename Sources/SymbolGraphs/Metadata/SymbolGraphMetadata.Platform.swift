import BSONDecoding
import BSONEncoding

extension SymbolGraphMetadata
{
    @frozen public
    struct Platform:Equatable, Hashable, Sendable
    {
        public
        let lowercased:String

        @inlinable internal
        init(lowercased:String)
        {
            self.lowercased = lowercased
        }
    }
}
extension SymbolGraphMetadata.Platform
{
    @inlinable public static
    var android:Self { .init(lowercased: "android") }

    @inlinable public static
    var driverKit:Self { .init(lowercased: "driverkit") }

    @inlinable public static
    var iOS:Self { .init(lowercased: "ios") }

    @inlinable public static
    var linux:Self { .init(lowercased: "linux") }

    @inlinable public static
    var macOS:Self { .init(lowercased: "macos") }

    @inlinable public static
    var macCatalyst:Self { .init(lowercased: "maccatalyst") }

    @inlinable public static
    var openBSD:Self { .init(lowercased: "openbsd") }

    @inlinable public static
    var tvOS:Self { .init(lowercased: "tvos") }

    @inlinable public static
    var wasi:Self { .init(lowercased: "wasi") }

    @inlinable public static
    var watchOS:Self { .init(lowercased: "watchos") }

    @inlinable public static
    var windows:Self { .init(lowercased: "windows") }
}
extension SymbolGraphMetadata.Platform:CustomStringConvertible
{
    @inlinable public
    var description:String { self.lowercased }
}
extension SymbolGraphMetadata.Platform:LosslessStringConvertible
{
    @inlinable public
    init(_ description:String)
    {
        self.init(lowercased: description.lowercased())
    }
}
extension SymbolGraphMetadata.Platform:BSONStringDecodable, BSONStringEncodable
{
}
