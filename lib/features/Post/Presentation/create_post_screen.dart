import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Presentation/post_preview_screen.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:instagram/features/Post/logics/gallery_cubit.dart';
import 'package:instagram/features/Post/logics/gallery_state.dart';

class CreatePostScreen extends StatelessWidget {
  final String currentUserId;
  const CreatePostScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GalleryCubit()..loadGallery(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("New Post"),
          actions: [
            BlocBuilder<GalleryCubit, GalleryState>(
              builder: (context, state) {
                if (state is! GalleryLoaded || state.selectedAssets.isEmpty) {
                  return const SizedBox();
                }
                return TextButton(
                  onPressed: () async {
                    final files = <File>[];
                    for (final asset in state.selectedAssets) {
                      final file = await asset.file;
                      if (file != null) files.add(file);
                    }

                    if (files.isEmpty) return;

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostPreviewScreen(
                          currentUserId: currentUserId,
                          imageFiles: files,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            if (state is GalleryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GalleryError) {
              return Center(child: Text(state.message));
            } else if (state is GalleryLoaded) {
              final selected = state.selectedAssets;
              return Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: selected.isEmpty
                        ? const Center(child: Text("Select an image"))
                        : PageView.builder(
                            itemCount: selected.length,
                            itemBuilder: (context, index) {
                              final asset = selected[index];
                              return FutureBuilder<File?>(
                                future: asset.file,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: Text("Error loading image"),
                                    );
                                  }
                                  return Image.file(
                                    snapshot.data!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(2),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                      itemCount: state.assets.length,
                      itemBuilder: (context, index) {
                        final asset = state.assets[index];
                        final isSelected = state.selectedAssets.contains(asset);

                        return GestureDetector(
                          onTap: () {
                            context.read<GalleryCubit>().toggleSelection(asset);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FutureBuilder<Uint8List?>(
                                future: asset.thumbnailDataWithSize(
                                  const ThumbnailSize(200, 200),
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(color: Colors.grey[300]);
                                  }
                                  if (!snapshot.hasData) {
                                    return Container(color: Colors.grey[400]);
                                  }
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                              if (isSelected)
                                Container(
                                  color: Colors.black45,
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
