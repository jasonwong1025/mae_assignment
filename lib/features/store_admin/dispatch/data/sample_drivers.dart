import 'models/driver.dart';

/// Sample drivers for Dispatch. Ids match [sampleDriverLocations].
/// TODO: delete once orders and driver status come from Firestore.
List<Driver> sampleDrivers() {
  return const [
    Driver(
      id: 'w7',
      name: 'Amir Hamzah',
      isOnDuty: true,
      currentOrderNumber: 2290,
    ),
    Driver(
      id: 'w8',
      name: 'Firdaus Rahim',
      isOnDuty: true,
      currentOrderNumber: 2285,
    ),
    Driver(
      id: 'w9',
      name: 'Lau Wei Jie',
      isOnDuty: true,
      currentOrderNumber: 1178,
    ),
    Driver(id: 'w10', name: 'Kumar Selvam', isOnDuty: true),
    Driver(id: 'w25', name: 'Azlan Shah', isOnDuty: true),
    Driver(id: 'w26', name: 'Benjamin Yap', isOnDuty: true),
    Driver(id: 'w27', name: 'Danish Iskandar', isOnDuty: true),
    Driver(id: 'w28', name: 'Ganesh Pillai', isOnDuty: true),
    Driver(id: 'w29', name: 'Haziq Amir', isOnDuty: true),
    Driver(id: 'w30', name: 'Jason Tan', isOnDuty: true),
    Driver(id: 'w31', name: 'Marcus Ho', isOnDuty: true),
    Driver(id: 'w32', name: 'Naveen Kumar', isOnDuty: true),
    Driver(id: 'w33', name: 'Ridzuan Ali', isOnDuty: false),
    Driver(id: 'w34', name: 'Tan Wei Loon', isOnDuty: false),
  ];
}
