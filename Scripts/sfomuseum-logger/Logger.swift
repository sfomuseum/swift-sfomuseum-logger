import ArgumentParser
import SFOMuseumLogger

@main
struct Logger: AsyncParsableCommand {
    
    @Option(help: "The host name to listen for new connections")
    var label: String = "org.sfomuseum.logger"
    
    @Option(help: "The number of threads to use for the GRPC server")
    var console: Bool = true
    
    @Option(help: "Write logs to specific log file (optional)")
    var log_file: String?
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    
    func run() async throws {
        
        let opts = SFOMuseumLoggerOptions(label: label, console: console, verbose: verbose)
        let logger = try NewSFOMuseumLogger(opts)
        
        logger.info("Hello world")
    }
}

