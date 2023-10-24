import ArgumentParser
import SFOMuseumLogger
import Foundation

@main
struct App: AsyncParsableCommand {
    
    @Option(help: "The label to use for log events")
    var label: String = "org.sfomuseum.logger"
    
    @Option(help: "Log events to the console")
    var console: Bool = true
    
    @Option(help: "Log events to a specific log file (optional)")
    var log_file: String? = nil
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    func run() async throws {
        
        print("OMG")
        let opts = SFOMuseumLoggerOptions(label: label, console: console, verbose: verbose)
        
        print("WTF")
        var logger = try NewSFOMuseumLogger(opts)
        logger[metadataKey: "request-uuid"] = "\(UUID())"
        
        print("POO")
        logger.info("Hello world")
    }
}

