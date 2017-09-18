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

#if swift(>=4)
    // We can't do this yet, so fallback on the older workaround
    // extension Preferences: Codable { }
#else
    protocol Codable { }
    
    // Rewrite just enough of JSONDecoder so that it satifies our needs
    class JSONDecoder {
        func decode<T: Codable>(_ type: T.Type, from data: Data) throws -> T? {
            if type == Preferences.self {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let preferences = Preferences()
                (json?[Preferences.parameterAlignment] as? Bool).flatMap {
                    preferences.areParametersAligned = $0
                }
                (json?[Preferences.removeSemicolons] as? Bool).flatMap {
                    preferences.areSemicolonsRemoved = $0
                }
                return preferences as? T
            } else {
                return nil
            }
        }
    }
#endif
