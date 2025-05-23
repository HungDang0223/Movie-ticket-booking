import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';

class VnpayPaymentUseCase implements UseCase<String, double> {
  final PaymentRepository _repository;

  VnpayPaymentUseCase(this._repository);
  @override
  Future<Result<String>> call(double amount) {
    // TODO: implement call
    throw UnimplementedError();
  }
}