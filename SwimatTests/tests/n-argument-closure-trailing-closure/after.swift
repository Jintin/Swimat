// #151
UIView.animate(withDuration: 0.3, animations: {
    someCode()
}) { finished in
    afterAnimation()
}
