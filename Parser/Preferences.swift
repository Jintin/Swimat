import Foundation

class Preferences: Codable {
    static let parameterAlignment = "areParametersAligned"
    static let removeSemicolons = "areSemicolonsRemoved"

    private static let sharedUserDefaults = {
        UserDefaults(suiteName: "com.jintin.swimat.configuration")!
    }()

    static var areParametersAligned: Bool {
        get {
            return Preferences.sharedUserDefaults.bool(forKey: Preferences.parameterAlignment)
        }
        set {
            Preferences.sharedUserDefaults.set(newValue, forKey: Preferences.parameterAlignment)
            Preferences.sharedUserDefaults.synchronize()
        }
    }
    var areParametersAligned = false

    static var areSemicolonsRemoved: Bool {
        get {
            return Preferences.sharedUserDefaults.bool(forKey: Preferences.removeSemicolons)
        }
        set {
            Preferences.sharedUserDefaults.set(newValue, forKey: Preferences.removeSemicolons)
            Preferences.sharedUserDefaults.synchronize()
        }
    }
    var areSemicolonsRemoved = false
}
