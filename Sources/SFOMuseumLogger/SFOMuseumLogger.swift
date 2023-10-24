import Foundation
import Logging
import Puppy

internal struct logFormatter: LogFormattable {
    private let dateFormat = DateFormatter()
    
    init() {
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }
    
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String,
                       file: String, line: UInt, swiftLogInfo: [String : String],
                       label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date, withFormatter: dateFormat)
        let fileName = fileName(file)
        let moduleName = moduleName(file)
        return "\(date) \(threadID) [\(level)] \(swiftLogInfo) \(moduleName)/\(fileName)#L.\(line) \(function) \(message)"
    }
}

public struct SFOMuseumLoggerOptions {
    public var label: String
    public var console: Bool = true
    public var logfile: String?
    public var verbose: Bool = false
    
    public init(label: String, console: Bool, logfile: String? = nil, verbose: Bool) {
        self.label = label
        self.console = console
        self.logfile = logfile
        self.verbose = verbose
    }
}

public func NewSFOMuseumLogger(_ options: SFOMuseumLoggerOptions) throws -> Logger  {
    
    let log_format = logFormatter()
    
    // This does not work (yet) as advertised. Specifically only
    // the first handler added to puppy ever gets invoked. Dunno...
    // https://github.com/sushichop/Puppy/issues/89
    
    var puppy = Puppy()
    
    if options.logfile != nil {
        
        let log_url = URL(fileURLWithPath: options.logfile!).absoluteURL
        
        let rotationConfig = RotationConfig(suffixExtension: .numbering,
                                            maxFileSize: 30 * 1024 * 1024,
                                            maxArchivedFilesCount: 5)
        
        let fileRotation = try FileRotationLogger(options.label,
                                                  logFormat: log_format,
                                                  fileURL: log_url,
                                                  rotationConfig: rotationConfig
        )
        
        puppy.add(fileRotation)
    }
    
    // See notes above
    
    if options.console {
        let console = ConsoleLogger(options.label, logFormat: log_format)
        puppy.add(console)
    }
    
    LoggingSystem.bootstrap {
        
        var handler = PuppyLogHandler(label: $0, puppy: puppy)
        handler.logLevel = .info
        
        if options.verbose {
            handler.logLevel = .trace
        }
        
        return handler
    }
    
    let logger = Logger(label: options.label)
    return logger
    
}
