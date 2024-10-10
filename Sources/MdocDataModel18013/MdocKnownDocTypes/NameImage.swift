import Foundation

public struct NameImage: Sendable {
	public init(name: String, image: Data, ns: String? = nil) {
		self.name = name
		self.image = image
		self.ns = ns
	}
	public let ns: String?
	public let name: String
	public let image: Data
}
