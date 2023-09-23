@frozen public
enum AcceptType:Equatable, Hashable, Sendable
{
    case application(MediaSubtype?)
    case audio      (MediaSubtype?)
    case font       (MediaSubtype?)
    case image      (MediaSubtype?)
    case model      (MediaSubtype?)
    case text       (MediaSubtype?)
    case video      (MediaSubtype?)
}
