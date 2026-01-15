import Foundation

/// A repository of ZkSystemProtocol implementations.
public struct ZkSystemRepository {
    private var systems: [any ZkSystemProtocol] = []
    
    public init(systems: [any ZkSystemProtocol] = []) {
        self.systems = systems
 }
    
    /// Registers a new ZkSystemProtocol into the repository.
    ///
    /// - Parameter zkSystem: The ZkSystemProtocol implementation to add.
    /// - Returns: This repository instance for method chaining
    @discardableResult
    public mutating func add(_ zkSystem: any ZkSystemProtocol) -> ZkSystemRepository {
        systems.append(zkSystem)
        return self
    }
    
    /// Looks up a registered ZkSystemProtocol by name.
    ///
    /// - Parameter zkSystemName: The name of the system to find.
    /// - Returns: The matching ZkSystemProtocol, or nil if not found.
    public func lookup(_ zkSystemName: String) -> (any ZkSystemProtocol)? {
        return systems.first { $0.name == zkSystemName }
    }
    
    /// Returns a list of all ZkSystemSpec from each ZkSystem implementation.
    ///
    /// - Returns: A list of ZkSystemSpec.
    public func getAllZkSystemSpecs() -> [ZkSystemSpec] {
        return systems.flatMap { $0.systemSpecs }
    }
}
