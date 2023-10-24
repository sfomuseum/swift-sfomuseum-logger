import ArgumentParser
import SFOMuseumLogger

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
    
    @Argument
    var args: [String]
    
    func run() throws {
        
        let opts = SFOMuseumLoggerOptions(label: label, console: console, logfile: logfile, verbose: verbose)
        var logger = try NewSFOMuseumLogger(opts)
        
        logger[metadataKey: "metadata"] = "debug"
        
        for txt in args {
            logger.info("\(txt)")
        }
    }
}

