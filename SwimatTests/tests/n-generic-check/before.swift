// #201
var currentState: TutorialState? {
    if let states = states, currentStateIndex < states.count, currentStateIndex >= 0 {
        return states[currentStateIndex]
    }
    return nil
}
