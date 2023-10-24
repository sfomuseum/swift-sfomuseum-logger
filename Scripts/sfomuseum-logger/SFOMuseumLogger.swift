import ArgumentParser
import SFOMuseumLogger

@main
struct SFOMuseumLogger: AsyncParsableCommand {
    
    @Option(help: "The host name to listen for new connections")
    var label: String = "org.sfomuseum.logger"
    
    @Option(help: "The number of threads to use for the GRPC server")
    var console: Bool = true
    
    @Option(help: "Write logs to specific log file (optional)")
    var log_file: String? = nil
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    func run() async throws {
        
        print("OMG")
        let opts = SFOMuseumLoggerOptions(label: label, console: console, verbose: verbose)
        
        print("WTF")
        let logger = try NewSFOMuseumLogger(opts)
        // logger[metadataKey: "request-uuid"] = "\(UUID())"
        
        print("POO")
        logger.info("Hello world")
    }
}

