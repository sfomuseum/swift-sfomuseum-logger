# swift-sfomuseum-logger

An opinionated Swift package for creating `log-swift` instances in a SFO Museum context

## Known-knowns

Under the hood this package uses the [Puppy](https://github.com/sushichop/Puppy) library for logging to both the console and a rotating log file. There is an open ticket to (hopefully) address a problem where messages are only dispatched to the first logger. In this instance that means messages are dispatched to an optional log file and then the console meaning if you specify a `--log_file` flag logging message _will not_ be dispatched to the console.

* https://github.com/sushichop/Puppy/issues/89

## See also

* https://github.com/apple/swift-log
* https://github.com/sushichop/Puppy