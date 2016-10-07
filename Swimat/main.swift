//
//  main.swift
//  swimat
//
//  Created by Saagar Jha on 10/7/16.
//  Copyright © 2016 jintin. All rights reserved.
//

import CoreServices
import Foundation

let invalidOption: Int32 = 1
let invalidIndent: Int32 = 2

var indentSize = 0
var indent: String {
	if indentSize <= 0 {
		return "\t"
	} else {
		return String(repeating: " ", count: indentSize)
	}
}
var force = false

var lookingForIndent = false

func printToError(_ string: String) {
	guard let data = "\(string)\n".data(using: .utf8) else {
		return
	}
	FileHandle.standardError.write(data)
}

for var argument in CommandLine.arguments.dropFirst() {
	if argument.hasPrefix("-") {
		argument.remove(at: argument.startIndex)
		switch argument {
		case "f":
			force = !force
		case "i":
			lookingForIndent = true
		default:
			printToError("-\(argument) is not a valid option.\nValid options are -i and -f.")
			exit(invalidOption)
		}
	} else {
		if (lookingForIndent) {
			guard let size = Int(argument) else {
				printToError("\(argument) is not a valid indent size. Exiting.")
				exit(invalidIndent)
			}
			indentSize = size
			lookingForIndent = false
		} else {
			let file = URL(fileURLWithPath: argument)
			if force || UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (file.pathExtension) as CFString, nil)?.takeRetainedValue() as? String ?? "" == "public.swift-source" {
				SwiftParser.indentChar = indent
				let parser = SwiftParser(string: try String(contentsOf: file))
				let formattedText = try parser.format()
				try formattedText.write(to: file, atomically: true, encoding: .utf8)
				print("\(argument) was formatted successfully.")
			} else {
				print("\(argument) doesn't appear to be a Swift file. Skipping.")
			}
		}
	}
}
