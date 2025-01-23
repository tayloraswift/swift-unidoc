import Availability
import BSON
import Testing

@Suite
enum Availabilities
{
    @Test
    static func Basic() throws
    {
        let availability:Availability = .init(.init(
            deprecated: .unconditionally,
            renamed: "Renamed",
            message: "Message"))

        let bson:BSON.Document = .init(encoding: availability)
        let decoded:Availability = try .init(bson: bson)

        #expect(availability == decoded)
    }
    @Test
    static func Agnostic() throws
    {
        let availability:Availability = .init(agnostic: [
                .swift: .init(
                    deprecated: .since(.minor(.v(5, 8))),
                    renamed: "Renamed",
                    message: "Message"),
            ])

        let bson:BSON.Document = .init(encoding: availability)
        let decoded:Availability = try .init(bson: bson)

        #expect(availability == decoded)
    }
    @Test
    static func Platform() throws
    {
        let availability:Availability = .init(platforms: [
                .macOS: .init(
                    unavailable: .unconditionally,
                    deprecated: .since(.patch(.v(0, 0, 0))),
                    introduced: .patch(.v(5, 6, 7)),
                    obsoleted: .minor(.v(8, 9)),
                    renamed: "Renamed",
                    message: "Message"),
            ])

        let bson:BSON.Document = .init(encoding: availability)
        let decoded:Availability = try .init(bson: bson)

        #expect(availability == decoded)
    }
}
