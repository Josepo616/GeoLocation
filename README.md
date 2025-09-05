
# GeoLocation  

An iOS application built with **SwiftUI**, **Combine**, and **CoreLocation** that enables:  
- Real-time user location tracking.  
- Interactive map with custom pins.  
- Saving and listing visited places.  
- Measuring distance traveled from the initial location.  
- Detecting network connectivity and handling related errors.  

---

## Features  

- **MapKit Integration**: Displays a map with the user’s current location and dropped pins.  
- **Tap Interactions**: Tap the map to get place details and coordinates.  
- **Location Tracking**: Updates user location every 5 seconds, saving significant changes (≥20m).  
- **Reverse Geocoding**: Converts coordinates into readable place names.  
- **Error Handling**: Manages cases such as denied permissions, no connection, unavailable location, or geocoding failures.  
- **Visited Places**: Keeps a history list of visited locations with details (name, coordinates, time).  
- **Connectivity Monitoring**: Detects real internet access using `NWPathMonitor` and periodic checks.  

---

## Tech Stack  

- **SwiftUI** → Declarative UI framework.  
- **Combine** → Reactive programming with publishers/subscribers.  
- **CoreLocation** → Location services for iOS.  
- **MapKit** → Maps, user location, and annotations.  
- **Network (NWPathMonitor)** → Monitoring network connectivity.  

---

## Architecture  

The app follows the **MVVM (Model - View - ViewModel)** pattern:  

- **Models**  
  - `VisitedPlaceModel`: Represents a visited place (name, coordinates, date, timestamp).  

- **Services**  
  - `LocationService`: Wraps `CLLocationManager`, exposes Combine publishers for location, permissions, and errors.  
  - `NetworkMonitorService`: Tracks connectivity, verifies internet access every 5 seconds.  
  - `LocationErrorMapper`: Maps CoreLocation errors into domain-specific `APIError`.  

- **ViewModel**  
  - `GeoLocationViewModel`: Handles business logic, coordinates services, and maintains reactive state.  

- **Views**  
  - `MapView`: Main tab container.  
  - `MapContentView`: Map view with user data.  
  - `MapSection`: Displays the map, handles taps, pins, and errors.  
  - `TapMapView`: UIKit `MKMapView` wrapper with tap handling.  
  - `VisitedPlacesView`: Displays visited places in a list.  
  - `LocationFormView`: Shows location details (latest, current, distance).  

---

## Error Handling  

The app defines a custom `APIError` enum covering:  

-  Location permission denied.  
- No internet connection.  
- Location unavailable.  
- Geocoding failure.  
- Unknown errors.  

All errors are surfaced to the user through alerts or disabled states.  

---

## 📂 Project Structure  

![ProjectStruct.png](https://raw.githubusercontent.com/Josepo616/GeoLocation/refs/heads/week-08/ProjectStruct.png)
