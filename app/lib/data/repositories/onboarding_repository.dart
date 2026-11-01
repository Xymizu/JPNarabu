abstract interface class OnboardingRepository {
  bool get isCompleted;

  void complete();
}

class InMemoryOnboardingRepository implements OnboardingRepository {
  bool _isCompleted = false;

  @override
  bool get isCompleted => _isCompleted;

  @override
  void complete() {
    _isCompleted = true;
  }
}
