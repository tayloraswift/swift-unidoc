import BSON
import Symbols

@available(*, deprecated, renamed: "Symbol.Edition")
public
typealias VolumeIdentidier = Symbol.Edition

extension Symbol.Edition:BSONStringEncodable, BSONStringDecodable
{
}
