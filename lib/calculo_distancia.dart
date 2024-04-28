import 'dart:math';

const double earthRadius = 6371000; // in meters

double degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  double dLat = degreesToRadians(lat2 - lat1);
  double dLon = degreesToRadians(lon2 - lon1);

  double a = pow(sin(dLat / 2), 2) +
      pow(sin(dLon / 2), 2) *
          cos(degreesToRadians(lat1)) *
          cos(degreesToRadians(lat2));
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

bool isWithinRadius(
    double lat1, double lon1, double lat2, double lon2, double radius) {
  double distance = calculateDistance(lat1, lon1, lat2, lon2);
  return distance <= radius;
}

void main() {
  // Example usage:
  // double latitude1 = 37.972377; // Latitude of point 1
  // double longitude1 = -1.207200; // Longitude of point 1
  // double latitude2 = 37.972182; // Latitude of point 2
  // double longitude2 = -1.207457; // Longitude of point 2
  // double radiusInMeters = 50; // Radius in meters

  // bool withinRadius = isWithinRadius(
  //     latitude1, longitude1, latitude2, longitude2, radiusInMeters);
  //print("Is within radius: $withinRadius");
}
