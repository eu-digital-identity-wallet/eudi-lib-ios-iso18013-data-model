import Foundation

extension Data {
    /// init from local file (test-only helper)
    init?(name: String, ext: String = "json", from bundle: Bundle = Bundle.main) {
        guard let url = bundle.url(forResource: name, withExtension: ext) else { return nil }
        try? self.init(contentsOf: url, options: .mappedIfSafe)
    }
}
