//
//  main.swift
//  swimat
//
//  Created by Saagar Jha on 10/7/16.
//  Copyright © 2016 jintin. All rights reserved.
//

import CoreServices
import Foundation

SwiftParser.indentChar = "\t"

for path in CommandLine.arguments.dropFirst() {
	let file = URL(fileURLWithPath: path)
	if UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (file.pathExtension) as CFString, nil)?.takeRetainedValue() as? String ?? "" == "public.swift-source" {
		let parser = SwiftParser(string: try String(contentsOf: file))
		let formattedText = try parser.format()
		try formattedText.write(to: file, atomically: true, encoding: .utf8)
	}
}
