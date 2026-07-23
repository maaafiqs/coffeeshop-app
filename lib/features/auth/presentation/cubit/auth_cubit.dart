import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void loginAsGuest() {
    emit(AuthGuest());
  }

  void loginAsUser(UserModel user) {
    emit(AuthAuthenticated(user: user));
  }

  void updateProfile(UserModel updatedUser) {
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  void logout() {
    emit(AuthInitial());
  }
}
