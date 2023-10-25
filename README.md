# swift-sfomuseum-logger

An opinionated Swift package for creating `log-swift` instances in a SFO Museum context

## Example

```
import SFOMuseumLogger

let opts = SFOMuseumLoggerOptions(
    label: "org.sfomuseum.logging",
    console: true,      // writes to swift-log StreamLogHandler.standardOutput handler
    logfile: true,      // writes to CocoaLumberjack DDFileLog handler
    max_logfiles: 5,    // maximum number of log files to keep (default: 7)
    verbose: false,     // if true all handler log levels will be set to .trace (default: false (.info log level))
)

var logger = try NewSFOMuseumLogger(opts)
logger[metadataKey: "metadata"] = "debug"

logger.info("Hello world")
```        

Which would produce this:

```
2023-10-25T10:57:56-0700 info org.sfomuseum.logger : metadata=debug [sfomuseum_logger] hello world
```

If you want to append your own `swift-log` log handlers you can optionally assign them to the `handlers` property in `SFOMuseumLoggerOptions`. For example:

```
import SFOMuseumLogger
import Logging

let opts = SFOMuseumLoggerOptions(
    label: "org.sfomuseum.logging",
    console: true, 
    logfile: true,
    max_logfiles: 5,
    verbose: false,
)

var handlers = DefaultSFOMuseumLogHandlers(opts)
handlers.append(StreamLogHandler.standardError(label: label)

opts.handlers = handlers
let logger = try NewSFOMuseumLogger(opts)
```

## See also

* https://github.com/apple/swift-log
* https://github.com/CocoaLumberjack/CocoaLumberjack
