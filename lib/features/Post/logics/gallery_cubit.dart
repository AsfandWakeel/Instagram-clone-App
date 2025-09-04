import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit() : super(GalleryLoading());

  Future<void> loadGallery() async {
    emit(GalleryLoading());

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      emit(GalleryError("Permission denied"));
      return;
    }

    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isEmpty) {
        emit(GalleryError("No albums found"));
        return;
      }

      final recentAlbum = albums.first;
      final List<AssetEntity> assets = await recentAlbum.getAssetListPaged(
        page: 0,
        size: 200,
      );

      if (assets.isEmpty) {
        emit(GalleryError("No images found"));
        return;
      }

      emit(GalleryLoaded(assets));
    } catch (e) {
      emit(GalleryError("Failed to load gallery: $e"));
    }
  }

  void toggleSelection(AssetEntity asset) {
    if (state is GalleryLoaded) {
      final loaded = state as GalleryLoaded;
      final selected = List<AssetEntity>.from(loaded.selectedAssets);

      if (selected.contains(asset)) {
        selected.remove(asset);
      } else {
        selected.add(asset);
      }

      emit(GalleryLoaded(loaded.assets, selectedAssets: selected));
    }
  }
}
