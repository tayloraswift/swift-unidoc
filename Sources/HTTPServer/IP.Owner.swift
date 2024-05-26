import IP

extension IP
{
    @frozen public
    enum Owner:Equatable, Hashable, Sendable
    {
        case amazon
        /// Something running on an EC2 instance. Almost always harmful, but a human
        /// user with a proxy running on AWS might also get this classification.
        case amazonEC2
        case bingbot
        /// Something running on a GCP instance. Almost always harmful, but a human
        /// user with a proxy running on GCP might also get this classification.
        case gcp
        case google
        case googlebot

        case github

        /// The IP address is known to belong to a service, but the owner itself is not known.
        case known

        /// The IP address could not be mapped to an owner because the tables have
        /// not been initialized yet. This is a distinct state from the ``known`` case, because
        /// the IP might still belong to one of the enumerated services.
        case unknown
    }
}
extension IP.Owner:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .amazon:       "Amazon"
        case .amazonEC2:    "Amazon EC2"
        case .bingbot:      "Bingbot"
        case .gcp:          "Google Cloud Platform"
        case .google:       "Google"
        case .googlebot:    "Googlebot"
        case .github:       "GitHub"
        case .known:        "Known"
        case .unknown:      "Unknown"
        }
    }
}
