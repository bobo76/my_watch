# My Watch - Modern Garmin Watch Face

A modern, feature-rich watch face for Garmin Connect IQ devices with a clean design, battery indicator, and comprehensive unit testing.

## Features

- **Modern Design**: Clean, minimalist interface with navy blue theme
- **Analog Clock**: Hour, minute, and second hands with smooth movement
- **60 Tick Marks**: Visual hour and minute markers around the watch face
- **Battery Integration**: Color-coded battery level indicator integrated into tick marks
  - Green: >30% battery
  - Yellow: 20-30% battery
  - Red: <20% battery
  - Text warning when battery drops below 40%
- **Date Display**: Day of week and date with rounded background
- **Sleep Mode Optimization**: Second hand stops during sleep to save battery

## Compatibility

- **Primary Device**: Garmin Forerunner 245 Music (fr245m)
- **Minimum API Level**: 3.3.0
- **Language**: English

## Installation

### From Source

1. Clone this repository
2. Open in Visual Studio Code with Garmin Connect IQ extension
3. Build the project (see [Building](#building))
4. Load to your device via USB or simulator

### From Store
_Coming soon to Garmin Connect IQ Store_

## Development Setup

### Prerequisites

- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (v8.3.0 or higher)
- Visual Studio Code with Connect IQ extension (recommended)
- Developer key for signing builds

### Environment Setup

1. Install Garmin Connect IQ SDK:
   ```bash
   # SDK typically installed at:
   ~/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-8.3.0-2025-09-22-5813687a0
   ```

2. Generate developer key (if you don't have one):
   ```bash
   openssl genrsa -out developer_key 4096
   openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key -out developer_key.der -nocrypt
   ```

3. Clone and setup:
   ```bash
   git clone <repository-url>
   cd my_watch
   ```

## Building

### Command Line Build

```bash
# Build for Forerunner 245 Music
monkeyc -d fr245m \
  -f monkey.jungle \
  -o bin/my_watch.prg \
  -y /path/to/developer_key \
  -w
```

### VS Code Build

1. Open project in VS Code
2. Press `Ctrl+Shift+B` or run "Monkey C: Build for Device"
3. Select target device: `fr245m`

### Build Output

- Compiled binary: `bin/my_watch.prg` (~121 KB)
- Debug symbols: Auto-generated during build

## Testing

This project includes comprehensive unit tests for all logic functions.

### Running Tests

See [TESTING.md](TESTING.md) for detailed testing instructions.

Quick start:
```monkey-c
// Add to my_watchApp.mc initialize() for debug builds
if (DEBUG) {
  runTests();
}
```

### Test Coverage

- 46 unit tests covering:
  - Mathematical functions (polar coordinate conversions)
  - Time and angle calculations
  - Battery logic and color thresholds
  - All pure logic functions

## Project Structure

```
my_watch/
├── source/
│   ├── my_watchApp.mc           # Application entry point
│   ├── my_watchView.mc          # Main watch face view
│   ├── modernWatchDrawer.mc     # Modern watch face drawing logic
│   ├── classicWatchDrawer.mc    # Classic watch face (alternative)
│   ├── WatchLogic.mc            # Pure logic functions (testable)
│   ├── TestFramework.mc         # Unit testing framework
│   ├── WatchLogicTests.mc       # Unit tests
│   └── TestRunner.mc            # Test execution runner
├── resources/
│   ├── layouts/                 # UI layouts
│   ├── drawables/               # Images and icons
│   └── strings/                 # Localization strings
├── bin/                         # Build output
├── manifest.xml                 # App manifest
├── monkey.jungle                # Build configuration
├── README.md                    # This file
└── TESTING.md                   # Testing documentation
```

## Code Architecture

### Separation of Concerns

- **View Layer** (`my_watchView.mc`): Handles lifecycle events and coordinates drawing
- **Drawing Layer** (`modernWatchDrawer.mc`): Manages all graphics rendering
- **Logic Layer** (`WatchLogic.mc`): Pure functions for calculations (fully tested)

### Key Design Decisions

1. **Cached System Calls**: Battery and time cached once per frame for performance
2. **Named Constants**: All magic numbers extracted to constants for maintainability
3. **Type Safety**: Explicit type declarations on all variables
4. **Sleep Optimization**: Second hand disabled during sleep mode
5. **Test Coverage**: All logic functions have comprehensive unit tests

## Performance Optimizations

- Cached system calls (reduced from 5 to 2 per frame)
- Named constants calculated once
- Conditional second hand rendering during sleep
- Efficient polar coordinate calculations

## Customization

### Changing Colors

Edit color constants in `modernWatchDrawer.mc`:
```monkey-c
var darkNavyBlue as Number = 0x000022;
var darkOrange as Number = 0xcc6600;
var navyBlue as Number = 0x000055;
```

### Adjusting Hand Sizes

Modify constants in `modernWatchDrawer.mc`:
```monkey-c
const HOUR_HAND_LENGTH_RATIO = 0.55;
const MINUTE_HAND_LENGTH_RATIO = 0.75;
const SECOND_HAND_LENGTH_RATIO = 0.85;
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests to ensure everything works
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style

- Use explicit type declarations
- Extract magic numbers to constants
- Add unit tests for new logic functions
- Follow Monkey C conventions
- Keep drawing code separate from logic

## Troubleshooting

### Build Fails with "Cannot resolve type"
- Ensure all imports are present at the top of the file
- Check SDK version compatibility

### Watch Face Doesn't Load
- Verify device compatibility (fr245m)
- Check minimum API level (3.3.0)
- Ensure developer key is valid

### Performance Issues
- Check if system calls are cached
- Verify sleep mode is working
- Profile with Garmin simulator

## License

[Add your license here]

## Acknowledgments

- Built with Garmin Connect IQ SDK
- Tested on Garmin Forerunner 245 Music
- Unit testing framework custom-built for Monkey C

## Contact

[Add your contact information]

---

**Version**: 1.0.0
**Last Updated**: 2025-11-11
**Device**: Garmin Forerunner 245 Music