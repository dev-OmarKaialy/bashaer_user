# Layer templates

The skeletons use the team template's names: `ApiVariables`, `ApiClient`, `HandlingApiManager`, `HandlingException`, `UseCase`, `RequestStatus`, `getIt`. If the Project profile maps a role to a different name, substitute it. Replace `Items`/`items` with the feature name.

## 1. Endpoint (`lib/core/unified_api/api_variables.dart`)
```dart
Uri getItemsUri({ParamsMap? params}) => _mainUri(path: 'items/', queryParameters: params);
```

## 2. Model (`data/models/items_model.dart`), built from a real response
```dart
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'items_model.freezed.dart';
part 'items_model.g.dart';

ItemsModel itemsModelFromJson(String str) => ItemsModel.fromJson(json.decode(str));

@freezed
sealed class ItemsModel with _$ItemsModel {
  const factory ItemsModel({
    @JsonKey(name: "data") List<ItemModel>? data,
  }) = _ItemsModel;

  factory ItemsModel.fromJson(Map<String, dynamic> json) => _$ItemsModelFromJson(json);
}
```

## 3. Datasource (`data/datasources/items_remote_datasource.dart`)
```dart
abstract class RemoteItemsDatasource {
  Future<ItemsModel> getItems(GetItemsParams params);
}

@Injectable(as: RemoteItemsDatasource)
class RemoteItemsDatasourceImpl with HandlingApiManager implements RemoteItemsDatasource {
  RemoteItemsDatasourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<ItemsModel> getItems(GetItemsParams params) {
    return wrapHandlingApi(
      tryCall: () => apiClient.get(ApiVariables().getItemsUri(params: params.toQuery())),
      jsonConvert: itemsModelFromJson,
    );
  }
}
```

## 4. Repository
```dart
// domain/repositories/items_repository.dart
abstract class ItemsRepository {
  Future<Either<Failure, ItemsModel>> getItems(GetItemsParams params);
}

// data/repositories/items_repository_impl.dart
@Injectable(as: ItemsRepository)
class ItemsRepositoryImpl with HandlingException implements ItemsRepository {
  ItemsRepositoryImpl({required this.remoteDatasource});

  final RemoteItemsDatasource remoteDatasource;

  @override
  Future<Either<Failure, ItemsModel>> getItems(GetItemsParams params) {
    return wrapHandling(tryCall: () => remoteDatasource.getItems(params));
  }
}
```

## 5. Use case + Params (`domain/usecases/get_items_usecase.dart`)
```dart
class GetItemsParams {
  const GetItemsParams({required this.page});

  final int page;

  ParamsMap toQuery() => {'page': '$page'};
}

@injectable
class GetItemsUsecase implements UseCase<ItemsModel, GetItemsParams> {
  GetItemsUsecase({required this.repository});

  final ItemsRepository repository;

  @override
  Future<Either<Failure, ItemsModel>> call(GetItemsParams params) => repository.getItems(params);
}
```

## 6. Bloc (`presentation/bloc/items_bloc.dart` + `part` files)
```dart
// items_event.dart
sealed class ItemsEvent extends Equatable {
  const ItemsEvent();

  @override
  List<Object?> get props => [];
}

final class GetItemsEvent extends ItemsEvent {
  const GetItemsEvent();
}

// items_state.dart
class ItemsState extends Equatable {
  const ItemsState({
    this.getItemsStatus = RequestStatus.init,
    this.items = const [],
    this.errorMessage,
  });

  final RequestStatus getItemsStatus;
  final List<ItemModel> items;
  final String? errorMessage;

  ItemsState copyWith({RequestStatus? getItemsStatus, List<ItemModel>? items, String? errorMessage}) {
    return ItemsState(
      getItemsStatus: getItemsStatus ?? this.getItemsStatus,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [getItemsStatus, items, errorMessage];
}

// items_bloc.dart
@injectable // screen-scoped: factory, provided with BlocProvider(create:)
class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  ItemsBloc(this._getItemsUsecase) : super(const ItemsState()) {
    on<GetItemsEvent>(_onGetItems);
  }

  final GetItemsUsecase _getItemsUsecase;

  Future<void> _onGetItems(GetItemsEvent event, Emitter<ItemsState> emit) async {
    emit(state.copyWith(getItemsStatus: RequestStatus.loading));
    final result = await _getItemsUsecase(const GetItemsParams(page: 1));
    result.fold(
      (failure) => emit(
        state.copyWith(getItemsStatus: RequestStatus.failed, errorMessage: failure.message),
      ),
      (model) => emit(
        state.copyWith(getItemsStatus: RequestStatus.success, items: model.data ?? const []),
      ),
    );
  }
}
```

## 7. Screen (`presentation/pages/items_screen.dart`)
```dart
class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ItemsBloc>()..add(const GetItemsEvent()),
      child: Scaffold(
        appBar: MainAppBar(title: 'items.title'.tr()),
        body: const ItemsBody(),
      ),
    );
  }
}

class ItemsBody extends StatelessWidget {
  const ItemsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsBloc, ItemsState>(
      buildWhen: (previous, current) =>
          previous.getItemsStatus != current.getItemsStatus || previous.items != current.items,
      builder: (context, state) {
        if (state.getItemsStatus.isLoading || state.getItemsStatus.isInit) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state.getItemsStatus.isFailed) {
          return MainErrorWidget(
            onPressed: () => context.read<ItemsBloc>().add(const GetItemsEvent()),
          );
        }
        if (state.items.isEmpty) return const ItemsEmptyView();
        return ListView.builder(
          itemCount: state.items.length,
          itemBuilder: (context, index) => ItemTile(item: state.items[index]),
        );
      },
    );
  }
}
```

## 8. Codegen
Run the codegen command from the Project profile. Then check that `git diff` on the DI config contains only the new registrations.
