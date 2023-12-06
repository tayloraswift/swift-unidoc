@frozen public
enum UnidocAPI
{
}

import JSON
import Unidoc

extension Unidoc.Package:JSONDecodable, JSONEncodable
{
}

import JSON
import Unidoc

extension Unidoc.Version:JSONDecodable, JSONEncodable
{
}
