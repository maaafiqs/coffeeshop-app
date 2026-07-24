import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';

class FavoriteState {
  final List<String> favoriteProductIds;
  final bool isLoading;

  FavoriteState({required this.favoriteProductIds, this.isLoading = false});

  factory FavoriteState.initial() => FavoriteState(favoriteProductIds: []);

  FavoriteState copyWith({List<String>? favoriteProductIds, bool? isLoading}) {
    return FavoriteState(
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(FavoriteState.initial());

  Future<void> loadFavorites(String userId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final favoriteIds = await DatabaseHelper.instance.getUserFavorites(userId);
      emit(state.copyWith(favoriteProductIds: favoriteIds, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> toggleFavorite(String userId, String productId) async {
    try {
      await DatabaseHelper.instance.toggleFavorite(userId, productId);
      // Reload to ensure state is in sync with DB
      await loadFavorites(userId);
    } catch (e) {
      // Handle error
    }
  }

  bool isFavorite(String productId) {
    return state.favoriteProductIds.contains(productId);
  }

  void clearFavorites() {
    emit(FavoriteState.initial());
  }
}
