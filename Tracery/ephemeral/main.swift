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
	
	func write(_ message: String, to: OutputType = .log) {
		switch to {
		case .log:
			if Ephemerald.verbose {
				print(message)
			}
		case .output:
			print(message)
		case .error:
			fputs("\(message)\n", stderr)
		}
	}
	
	func error(_ message: String, to: OutputType = .error) {
		switch to {
		case .log:
			write("\u{001B}[;m !!! Error: \(message) !!!", to: to)
		case .error:
			write("\u{001B}[0;33m !!! Error: \(message) !!!\u{001B}[;m", to: to)
		case .output:
			write("\u{001B}[0;33m !!! Error: \(message) !!!\u{001B}[;m", to: to)
		}
	}

	func printUsage() {
		
		let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
		
		write("usage:", to:.error)
		write("\(executableName) [-h] -i input-file [-o output-file]", to:.error)
	}
}

enum OptionType: String {
	case input = "-i"
	case output = "-o"
	case help = "-h"
	case verbose = "-v"
	case separator = "-s"
	case count = "-n"
	case unknown
	
	init(value: String) {
		switch value {
		case "-i": self = .input
		case "-o": self = .output
		case "-h": self = .help
		case "-v": self = .verbose
		case "-s": self = .separator
		case "-n": self = .count
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
		let count = Int(arguments[OptionType.count.rawValue] ?? "1") ?? 1
		let separator = arguments[OptionType.separator.rawValue] ?? "\n\n"

		if arguments[OptionType.help.rawValue] != nil || arguments.count == 0 || inputfile == nil {
			consoleIO.error("Can not find input file")
			consoleIO.printUsage()
			return
		}
		
		consoleIO.write("Processing: "+(inputfile ?? "stdin")+" => "+(outputfile ?? "stdout"))

		Tracery.logLevel = Ephemerald.verbose ? .verbose : .warnings

		var t:Tracery
		
		if inputfile != nil {
		
			let inputpath = FileManager.default.currentDirectoryPath  + "/" + inputfile!
			if FileManager.default.isReadableFile(atPath: inputpath) {
				consoleIO.write("Input from:\n" + inputpath)
				t = Tracery(path: inputpath)
			} else {
				consoleIO.error("File not found:\n" + inputpath)
				consoleIO.printUsage()
				return
			}
			
		} else {
		
			let input = readLine(strippingNewline:false)!.components(separatedBy: .newlines)
			t = Tracery(lines: input)
		}
		var output = ""
		for _ in 0..<count {
			output += t.expand("#origin#") + separator
		}
		
		if outputfile != nil {
			let outputpath = FileManager.default.currentDirectoryPath  + "/" + outputfile!
			let outURL = URL(fileURLWithPath: outputpath)
			do {
				try output.write(to: outURL, atomically: false, encoding: String.Encoding.unicode)
			} catch {
				consoleIO.error("Can not write to output file "+outputpath, to: .error)
				consoleIO.printUsage()
				return
			}
			consoleIO.write("Written to "+outputpath)
		} else {
			consoleIO.write(output, to:.output)
		}

	}
	func getOption(_ option: String) -> (option:OptionType, value: String) {
		return (OptionType(value: option), option)
	}
}


let ephemerald = Ephemerald()
ephemerald.staticMode()

