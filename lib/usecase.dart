import 'package:filemanager/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class UseCase<SuccessType, Parms> {
  Future<Either<Failure, SuccessType>> call(Parms parms);
}
