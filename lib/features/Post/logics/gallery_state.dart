import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

abstract class GalleryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<AssetEntity> assets;
  final List<AssetEntity> selectedAssets;

  GalleryLoaded(this.assets, {this.selectedAssets = const []});

  @override
  List<Object?> get props => [assets, selectedAssets];
}

class GalleryError extends GalleryState {
  final String message;
  GalleryError(this.message);

  @override
  List<Object?> get props => [message];
}
