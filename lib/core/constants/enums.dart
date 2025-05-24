// ignore_for_file: constant_identifier_names
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error
}
enum SeatStatus {
  Available,
  Reserved,
  TemporarilyReserved,
  Sold,
}
enum SeatType {
  Regular,
  VIP,
  Couple
}