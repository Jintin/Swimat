import Foundation
import XCTest

class TestSetup: NSObject {
    override init() {
        FormatTest.generateTests()
    }
}

func addInstanceMethod(named selector: Selector, to type: AnyClass, block: @convention(block) @escaping () -> ()) {
    let implementation = imp_implementationWithBlock(block)
    XCTAssert(class_addMethod(type, selector, implementation, "v@:"))
}
