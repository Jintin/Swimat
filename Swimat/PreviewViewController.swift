import CoreText
import Cocoa

class PreviewViewController: NSViewController, NSTextViewDelegate {

    static let sfMonoFontDescriptor: NSFontDescriptor? = {
        let descriptors = CTFontManagerCreateFontDescriptorsFromURL(URL(fileURLWithPath: "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SFMono-Regular.otf") as CFURL)
        return (descriptors as? [NSFontDescriptor])?.first
    }()

    @IBOutlet var codeTextView: NSTextView! {
        didSet {
            codeTextView.delegate = self
            guard let descriptor = PreviewViewController.sfMonoFontDescriptor,
                let size = codeTextView.font?.pointSize else {
                    return
            }
            codeTextView.font = NSFont(descriptor: descriptor, size: size)
        }
    }
    @IBOutlet var formattedCodeTextView: NSTextView! {
        didSet {
            formattedCodeTextView.textColor = .disabledControlTextColor
            guard let descriptor = PreviewViewController.sfMonoFontDescriptor,
                let size = formattedCodeTextView.font?.pointSize else {
                    return
            }
            formattedCodeTextView.font = NSFont(descriptor: descriptor, size: size)
        }
    }

    var timer = Timer()
    var lastFormatTime = 0.0

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesChanged), name: NSNotification.Name("SwimatPreferencesChangedNotification"), object: nil)
    }

    @objc func preferencesChanged(_ notification: Notification) {
        DispatchQueue.main.async { [unowned self] in
            self.rateLimitedFormat()
        }
    }

    func textDidChange(_ notification: Notification) {
        rateLimitedFormat()
    }

    func rateLimitedFormat() {
        timer.invalidate()
        timer = Timer(timeInterval: lastFormatTime + 0.1, target: self, selector: #selector(format), userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }

    @objc func format() {
        let text = codeTextView.string
        Indent.char = "\t"
        let formattedText = (try? SwiftParser(string: text).format()) ?? text
        let start = Date()
        DispatchQueue.main.async { [unowned self] in
            self.formattedCodeTextView.string = formattedText
            self.lastFormatTime = Date().timeIntervalSince(start)
        }
    }

}
