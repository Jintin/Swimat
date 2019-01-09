import Foundation

class Preferences: Codable {
    static let parameterAlignment = "areParametersAligned"
    static let removeSemicolons = "areSemicolonsRemoved"

    private static let sharedUserDefaults = {
        UserDefaults(suiteName: "com.jintin.swimat.configuration")!
    }()

    static var areParametersAligned: Bool {
        get {
            return getBool(key: parameterAlignment)
        }
        set {
            setBool(key: parameterAlignment, value: newValue)
        }
    }
    var areParametersAligned = false

    static var areSemicolonsRemoved: Bool {
        get {
            return getBool(key: removeSemicolons)
        }
        set {
            setBool(key: removeSemicolons, value: newValue)
        }
    }
    var areSemicolonsRemoved = false

    static func getBool(key: String) -> Bool {
        return sharedUserDefaults.bool(forKey: key)
    }

    static func setBool(key: String, value: Bool) {
        sharedUserDefaults.set(value, forKey: key)
        sharedUserDefaults.synchronize()
    }

}
