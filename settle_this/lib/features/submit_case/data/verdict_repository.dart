import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../verdict/domain/verdict.dart';
import '../domain/dispute_case_input.dart';

class VerdictException implements Exception {
  const VerdictException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'VerdictException($code): $message';
}

class VerdictRepository {
  FirebaseFunctions? _resolveFunctions() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFunctions.instanceFor(region: 'us-central1');
    } on FirebaseException {
      return null;
    }
  }

  Future<VerdictResponse> createVerdict(DisputeCaseInput input) async {
    final functions = _resolveFunctions();
    if (functions == null) {
      throw const VerdictException(
        'Backend not configured. Run "flutterfire configure" + deploy functions first.',
        code: 'firebase-not-initialized',
      );
    }

    try {
      final callable = functions.httpsCallable('createVerdict');
      final result = await callable.call<Map<Object?, Object?>>(
        input.toCallablePayload(),
      );
      return VerdictResponse.fromJson(result.data);
    } on FirebaseFunctionsException catch (error) {
      throw VerdictException(
        error.message ?? 'Could not generate a verdict.',
        code: error.code,
      );
    }
  }
}

final verdictRepositoryProvider = Provider<VerdictRepository>((ref) {
  return VerdictRepository();
});
