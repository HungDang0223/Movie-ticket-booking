// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
      (json['id'] as num).toInt(),
      json['show_name'] as String,
      json['show_banner'] as String,
      json['show_time_slot'] as String,
      (json['book_time'] as num).toInt(),
      json['cine_name'] as String,
      json['seat'] as String,
    );

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'id': instance.id,
      'show_name': instance.showName,
      'show_banner': instance.showBanner,
      'show_time_slot': instance.showTimeSlot,
      'book_time': instance.bookTime,
      'cine_name': instance.cineName,
      'seat': instance.seat,
    };
