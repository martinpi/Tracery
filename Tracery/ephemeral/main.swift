//
//  main.swift
//  ephemeral
//
//  Created by Martin Pichlmair on 17/12/2018.
//  Copyright © 2018 Benzi Ahamed. All rights reserved.
//

import Foundation
import Tracery

extension String {
	/// Checks if the string is prefixed with one of the prefixes specified in the array.
	func prefixedWithEither(_ of: [String]) -> Bool {
		return of.filter({ self.hasPrefix($0) }).count > 0
	}
}

extension CommandLine {
	///	Command line argument parsing function that helps Swift
	///	  applications designed for the command line parse and
	///	  access arguments easier and in less code by extending
	///	  the CommandLine enum.
	///
	///	The function recognises arguments prefixed with
	///	  `"-"`, `"--"` and `"+"` by default. Alternatively, you can
	///	  supply custom prefixes in the argumentPrefixes array.
	///
	///	Calling this function returns the arguments and their values
	///	  in a dictionary, with the name of the argument as the key.
	///
	///	For example, consider the argument array below:
	///
	///	    ["-a", "example", "--second", "5", "+t"]
	///
	///	Passing this array to this function returns the following
	///	  dictionary:
	///
	///	    ["-a": "example", "--second": "5", "+t": ""]
	///
	///	From there, your program can access its arguments through
	///	  the dictionary by using the argument name:
	///
	///	    let value = parsed["-a"]  // `value` is now "example"
	///
	///	- Parameter argumentPrefixes: An array that contains the
	///		string values for argument name prefixes. For example,
	///		with the array:
	///
	///       ["-", "--", "+"]
	///
	///		the parse function will recognise all arguments beginning
	///		with `"-"`, `"--"` and `"+"` as argument names.
	///
	/// - Returns: A String-based dictionary that contains argument names as keys
	///		and provided argument values as values.
	///
	///       [(argument name): (argument value)]
	static func parse(_ argumentPrefixes: [String] = ["-", "--"]) -> [String: String] {
		
		// Define the parsed dictionary.
		var parsed = [String: String]()
		
		// Iterate through each element of the arguments array.
		for pos in 0..<self.arguments.count {
			
			// If the argument is prefixed with either argument prefix...
			if self.arguments[pos].prefixedWithEither(argumentPrefixes) {
				
				// ...and the array contains at least one more non-prefixed element for the value...
				if (pos+1) < self.arguments.count && !self.arguments[pos+1].prefixedWithEither(argumentPrefixes) {
					
					// ...set the argument to the value in the dictionary.
					parsed[self.arguments[pos]] = self.arguments[pos+1]
				} else {
					
					// ...or if the argument is independent and does not have any values...
					// ...set the argument to an empty string value in the dictionary.
					parsed[self.arguments[pos]] = String()
				}
			}
		}
		
		// Return the parsed dictionary.
		return parsed
	}
}

class ConsoleIO {
	enum OutputType {
		case error
		case log
		case output
	}
	
	func writeMessage(_ message: String, to: OutputType = .log) {
		switch to {
		case .log:
			if Ephemerald.verbose {
				print("\u{001B}[;m\(message)")
			}
		case .output:
			print("\u{001B}[0;33m\(message)\u{001B}[;m")
		case .error:
			fputs("\u{001B}[0;31m\(message)\u{001B}[;m\n", stderr)
		}
	}

	func printUsage() {
		
		let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
		
		writeMessage("usage:")
		writeMessage("\(executableName) [-h] -i input-file [-o output-file]")
	}
}

enum OptionType: String {
	case input = "-i"
	case output = "-o"
	case help = "-h"
	case verbose = "-v"
	case unknown
	
	init(value: String) {
		switch value {
		case "-i": self = .input
		case "-o": self = .output
		case "-h": self = .help
		case "-v": self = .verbose
		default: self = .unknown
		}
	}
}

class Ephemerald {
	
	let consoleIO = ConsoleIO()
	static var verbose = false
	
	func staticMode() {
		let arguments = CommandLine.parse()
		Ephemerald.verbose = arguments[OptionType.verbose.rawValue] != nil

		let inputfile = arguments[OptionType.input.rawValue]
		let outputfile = arguments[OptionType.output.rawValue]
		
		if arguments[OptionType.help.rawValue] != nil {
			consoleIO.printUsage()
			return
		}
		
		consoleIO.writeMessage("Processing: "+(inputfile ?? "stdin")+" => "+(outputfile ?? "stdout"))

		Tracery.logLevel = Ephemerald.verbose ? .verbose : .warnings

		var output = ""
		
		if inputfile != nil {
		
			let inputpath = FileManager.default.currentDirectoryPath  + "/" + inputfile!
			if FileManager.default.isReadableFile(atPath: inputpath) {
				consoleIO.writeMessage("Input from:\n" + inputpath)
				output = Tracery(path: inputpath).expand("#origin#")
			}
			
		} else {
		
			let input = readLine(strippingNewline:false)!.components(separatedBy: .newlines)
			output = Tracery(lines: input).expand("#origin#")
		}
		
		if outputfile != nil {
			let outputpath = FileManager.default.currentDirectoryPath  + "/" + outputfile!
			let outURL = URL(fileURLWithPath: outputpath)
			do {
				try output.write(to: outURL, atomically: false, encoding: String.Encoding.unicode)
			} catch {
				consoleIO.writeMessage("Error writing to output file "+outputpath, to: .error)
				consoleIO.printUsage()
				return
			}
			consoleIO.writeMessage("Written to "+outputpath)
		} else {
			consoleIO.writeMessage(output, to:.output)
		}

	}
	func getOption(_ option: String) -> (option:OptionType, value: String) {
		return (OptionType(value: option), option)
	}
}


let ephemerald = Ephemerald()

if CommandLine.argc >= 2 {
	ephemerald.staticMode()
} else {
	ephemerald.consoleIO.printUsage()
}

