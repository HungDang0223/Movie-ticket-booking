import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/payment/data/models/zalopay_order_response.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';

class MomoPaymentUseCase implements UseCase<String, double> {
  final PaymentRepository _repository;

  MomoPaymentUseCase(this._repository);
  @override
  Future<Result<String>> call(double amount) {
    // TODO: implement call
    throw UnimplementedError();
  }
}