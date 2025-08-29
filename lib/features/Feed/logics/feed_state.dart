import 'package:equatable/equatable.dart';
import 'package:instagram/features/Post/Data/post_model.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<PostModel> posts;

  const FeedLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class FeedSuccess extends FeedState {
  final String message;

  const FeedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}
