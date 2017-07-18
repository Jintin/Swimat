// #147
let chain = UIView.animateAndChain(withDuration: 1.0,
                                   delay: 2.0,
                                   options: .curveEaseInOut,
                                   animations: {
                                       slideHideTitle()
                                       self.view.layoutIfNeeded()
                                   },
                                   completion: nil)
