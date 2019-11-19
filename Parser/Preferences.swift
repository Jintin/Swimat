import Foundation

class Preferences: Codable {
    enum Key: String, CodingKey {
        case parameterAlignment = "areParametersAligned"
        case removeSemicolons = "areSemicolonsRemoved"
    }

    static var shared: Preferences?
    private static let sharedUserDefaults = {
        UserDefaults(suiteName: "com.jintin.swimat.configuration")!
    }()

    static var areParametersAligned: Bool {
        get {
            return getBool(key: .parameterAlignment)
        }
        set {
            setBool(key: .parameterAlignment, value: newValue)
        }
    }
    var areParametersAligned: Bool

    static var areSemicolonsRemoved: Bool {
        get {
            return getBool(key: .removeSemicolons)
        }
        set {
            setBool(key: .removeSemicolons, value: newValue)
        }
    }
    var areSemicolonsRemoved: Bool

    init() {
        areParametersAligned = false
        areSemicolonsRemoved = false
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: Key.self)
        areParametersAligned = (try? values.decode(Bool.self, forKey: .parameterAlignment)) ?? false
        areSemicolonsRemoved = (try? values.decode(Bool.self, forKey: .removeSemicolons)) ?? false
    }

    static func getBool(key: Key) -> Bool {
        return sharedUserDefaults.bool(forKey: key.rawValue)
    }

    static func setBool(key: Key, value: Bool) {
        sharedUserDefaults.set(value, forKey: key.rawValue)
        sharedUserDefaults.synchronize()
    }

    func printDescription() {
        print(Key.parameterAlignment.rawValue, areParametersAligned)
        print(Key.removeSemicolons.rawValue, areSemicolonsRemoved)
    }

}
