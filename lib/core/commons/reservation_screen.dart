import 'package:flutter/material.dart';
import 'package:movie_tickets/core/commons/chat_screen.dart';
import 'package:movie_tickets/core/services/networking/ai_chatbot_service.dart';

class ReservationListScreen extends StatelessWidget {
  const ReservationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample reservations for demo
    final sampleReservations = [
      ReservationModel(
        id: 'RES001',
        customerName: 'Nguyễn Văn An',
        email: 'an.nguyen@email.com',
        phone: '0901234567',
        reservationDate: DateTime.now().add(const Duration(days: 1)),
        time: '19:00',
        numberOfGuests: 4,
        tableType: 'Window Table',
        specialRequests: 'Birthday celebration, need cake service',
      ),
      ReservationModel(
        id: 'RES002',
        customerName: 'Trần Thị Bình',
        email: 'binh.tran@email.com',
        phone: '0912345678',
        reservationDate: DateTime.now().add(const Duration(days: 2)),
        time: '18:30',
        numberOfGuests: 2,
        tableType: 'Regular Table',
        specialRequests: 'Vegetarian menu preferred',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Reservations'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleReservations.length,
        itemBuilder: (context, index) {
          final reservation = sampleReservations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  reservation.customerName[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                reservation.customerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${reservation.reservationDate.day}/${reservation.reservationDate.month}/${reservation.reservationDate.year} at ${reservation.time}'),
                  Text('${reservation.numberOfGuests} guests • ${reservation.tableType}'),
                ],
              ),
              trailing: const Icon(Icons.chat_bubble_outline),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(reservation: reservation),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}