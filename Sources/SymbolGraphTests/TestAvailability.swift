import Availability
import BSONDecoding
import BSONEncoding
import Testing

func TestAvailability(_ tests:TestGroup?)
{
    if  let tests:TestGroup = tests / "basic"
    {
        let availability:Availability = .init(.init(
            deprecated: .unconditionally,
            renamed: "Renamed",
            message: "Message"))

        tests.do
        {
            let bson:BSON.Document = .init(encoding: availability)

            let decoded:Availability = try .init(bson: .init(bson))

            tests.expect(availability ==? decoded)
        }
    }
    if  let tests:TestGroup = tests / "agnostic"
    {
        let availability:Availability = .init(agnostic:
            [
                .swift: .init(
                    deprecated: .since(.minor(.v(5, 8))),
                    renamed: "Renamed",
                    message: "Message"),
            ])

        tests.do
        {
            let bson:BSON.Document = .init(encoding: availability)
            let decoded:Availability = try .init(bson: .init(bson))

            tests.expect(availability ==? decoded)
        }
    }
    if  let tests:TestGroup = tests / "platform"
    {
        let availability:Availability = .init(platforms:
            [
                .macOS: .init(
                    unavailable: .unconditionally,
                    deprecated: .since(.patch(.v(0, 0, 0))),
                    introduced: .patch(.v(5, 6, 7)),
                    obsoleted: .minor(.v(8, 9)),
                    renamed: "Renamed",
                    message: "Message"),
            ])

        tests.do
        {
            let bson:BSON.Document = .init(encoding: availability)
            let decoded:Availability = try .init(bson: .init(bson))

            tests.expect(availability ==? decoded)
        }
    }
}
