import 'package:equatable/equatable.dart';
import 'package:instagram/features/Post/Data/post_model.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostModel> posts;
  const PostLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class PostSuccess extends PostState {
  final String message;
  const PostSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}
