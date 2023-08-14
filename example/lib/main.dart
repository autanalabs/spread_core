import 'dart:math';

import 'package:spread_core/spread_core.dart';

void main() async {
  await initServices();
  await initObservers();
  LoadUsersUseCase().execute();
}

Future initServices() async {
  Services()
      .init(userService: () => UserServiceImpl(repository: PostsApiPort()));
}

Future initObservers() async {
  UsersObserver().selfRegister();
}

// our ports:

abstract class PostsPort {
  Future<List<User>> findAllUsers();
}

class PostsApiPort implements PostsPort {
  Random random = Random();

  @override
  Future<List<User>> findAllUsers() async {
    final id = random.nextInt(1000);
    return Future.delayed(
        const Duration(
          seconds: 2,
        ),
        () => [
              User(id: id, name: "aaaa").generatePosts(),
              User(id: id + 500, name: "bbbb").generatePosts()
            ]);
  }
}

// our services:

abstract class UserService {
  Future<List<User>> getUsers();
}

class UserServiceImpl implements UserService {
  final PostsPort repository;

  UserServiceImpl({required this.repository});

  @override
  Future<List<User>> getUsers() async {
    return repository.findAllUsers();
  }
}

class Services {
  static final Services _singleton = Services._internal();
  factory Services() {
    return _singleton;
  }
  Services._internal();
  late final UserService userService;

  void init({
    required UserService Function() userService,
  }) async {
    this.userService = userService.call();
  }
}

// our models:

class User with StateEmitter implements Entity {
  final int id;
  final String name;
  final List<UserPost> posts = List.empty(growable: true);

  User({required this.id, required this.name});

  dynamic toDynamic() => {'id': id, 'name': name};

  static User fromDynamic(dynamic user) =>
      User(id: user['id'], name: user['name']);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
  }

  @override
  String get entityId => id.toString();

  User generatePosts() {
    _generateRandomPosts();
    return this;
  }

  void _generateRandomPosts() async {
    for (int i = 0; i < 100; i++) {
      final post = await _generateRandomPost();
      print('added post');
      posts.add(post);
      emitEntity<User>(this);
    }
  }

  Future<UserPost> _generateRandomPost() async {
    return Future.delayed(
        const Duration(
          seconds: 1,
        ),
        () => UserPost(content: 'random content'));
  }
}

class UserPost {
  final String content;

  UserPost({required this.content});
}

// our states:

abstract class UsersState {}

class LoadingUsers extends UsersState {}

class LoadedUsersSuccess extends UsersState {
  final List<User> users;

  LoadedUsersSuccess({required this.users});
}

class LoadedUsersFail extends UsersState {
  final Object? error;
  final StackTrace? stackTrace;

  LoadedUsersFail({required this.error, required this.stackTrace});
}

// our use case:

class LoadUsersUseCase with StateEmitter implements UseCase {
  @override
  void execute() async {
    final List<User>? usersCached =
        SpreadState().getNamed<List<User>>("users_cache");
    if (usersCached != null) {
      emit<UsersState>(LoadedUsersSuccess(users: usersCached));
    } else {
      emit<UsersState>(LoadingUsers());
      Services().userService.getUsers().then((users) {
        emitNamed("users_cache", users);
        emit<UsersState>(LoadedUsersSuccess(users: users));
      }).onError((error, stackTrace) {
        emit<UsersState>(LoadedUsersFail(error: error, stackTrace: stackTrace));
      });
    }
  }
}

// Create a State observer service to listen and handle states asynchronously

class UsersObserver extends SpreadObserver<UsersState> {
  @override
  onState(UsersState state) {
    print("UsersObserver Observed: ${state.toString()}");
  }
}
