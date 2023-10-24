import ArgumentParser
import SFOMuseumLogger
import Foundation

@main
struct App: AsyncParsableCommand {
    
    @Option(help: "The label to use for log events")
    var label: String = "org.sfomuseum.logger"
    
    @Option(help: "Log events to the console")
    var console: Bool = true
    
    @Option(help: "Log events to system log file")
    var logfile: Bool = false
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    func run() throws {
        
        let opts = SFOMuseumLoggerOptions(label: label, console: console, logfile: logfile, verbose: verbose)
        
        var logger = try NewSFOMuseumLogger(opts)
        logger[metadataKey: "request-uuid"] = "\(UUID())"
        logger.logLevel = .debug
        
        logger.info("Hello world WOO")
    }
}

