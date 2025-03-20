import 'package:movie_tickets/core/utils/multi_devices.dart';

extension Sizer on double {
  // flexible scale size for multi devicess
  double fs() {
    return MultiDevices.getValueByScale(this);
  }
}