extension AWS {
    @frozen public enum Region: String, Hashable, Sendable {
        case us_east_1 = "us-east-1"
        case us_east_2 = "us-east-2"
        case us_west_1 = "us-west-1"
        case us_west_2 = "us-west-2"

        case ca_central_1 = "ca-central-1"
        case ca_west_1 = "ca-west-1"

        case eu_central_1 = "eu-central-1"
        case eu_central_2 = "eu-central-2"
        case eu_north_1 = "eu-north-1"
        case eu_south_1 = "eu-south-1"
        case eu_south_2 = "eu-south-2"
        case eu_west_1 = "eu-west-1"
        case eu_west_2 = "eu-west-2"
        case eu_west_3 = "eu-west-3"

        case il_central_1 = "il-central-1"

        case ap_northeast_1 = "ap-northeast-1"
        case ap_northeast_2 = "ap-northeast-2"
        case ap_northeast_3 = "ap-northeast-3"
        case ap_southeast_1 = "ap-southeast-1"
        case ap_southeast_2 = "ap-southeast-2"
        case ap_southeast_3 = "ap-southeast-3"
        case ap_southeast_4 = "ap-southeast-4"
        case ap_east_1 = "ap-east-1"
        case ap_south_1 = "ap-south-1"
        case ap_south_2 = "ap-south-2"

        case me_central_1 = "me-central-1"
        case me_south_1 = "me-south-1"

        case sa_east_1 = "sa-east-1"

        case af_south_1 = "af-south-1"
    }
}
extension AWS.Region {
    @inlinable public var utf8: String.UTF8View { self.rawValue.utf8 }
}
extension AWS.Region: CustomStringConvertible {
    @inlinable public var description: String { self.rawValue }
}
extension AWS.Region: LosslessStringConvertible {
    @inlinable public init?(_ description: String) { self.init(rawValue: description) }
}
