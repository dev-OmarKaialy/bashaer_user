# Test templates

Names follow the team template (`Either`/dartz, `Failure`, `RequestStatus`, mocktail). Substitute names from the Project profile if they differ.

## Repository (fake datasource)
```dart
class FakeRemoteItemsDatasource implements RemoteItemsDatasource {
  FakeRemoteItemsDatasource({this.result, this.error});

  final ItemsModel? result;
  final Object? error;

  @override
  Future<ItemsModel> getItems(GetItemsParams params) async {
    if (error != null) throw error!;
    return result!;
  }
}

void main() {
  const params = GetItemsParams(page: 1);

  test('ItemsRepositoryImpl returns Right when datasource succeeds', () async {
    const model = ItemsModel(data: []);
    final repository = ItemsRepositoryImpl(
      remoteDatasource: FakeRemoteItemsDatasource(result: model),
    );

    final result = await repository.getItems(params);

    expect(result, const Right<Failure, ItemsModel>(model));
  });

  test('ItemsRepositoryImpl returns Left when datasource throws', () async {
    final repository = ItemsRepositoryImpl(
      remoteDatasource: FakeRemoteItemsDatasource(error: Exception('boom')),
    );

    final result = await repository.getItems(params);

    expect(result.isLeft(), isTrue);
  });
}
```

## Bloc state sequence (no `bloc_test` needed)
```dart
class FakeGetItemsUsecase implements GetItemsUsecase {
  FakeGetItemsUsecase(this.result);

  final Either<Failure, ItemsModel> result;

  @override
  ItemsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ItemsModel>> call(GetItemsParams params) async => result;
}

void main() {
  test('ItemsBloc emits loading then success when use case succeeds', () async {
    final bloc = ItemsBloc(FakeGetItemsUsecase(const Right(ItemsModel(data: []))));
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream.map((s) => s.getItemsStatus),
      emitsInOrder([RequestStatus.loading, RequestStatus.success]),
    );
    bloc.add(const GetItemsEvent());
    await expectation;
  });
}
```

## Mocking a third-party class (mocktail)
```dart
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

final storage = MockSecureStorage();
when(() => storage.read(key: 'counter')).thenAnswer((_) async => '3');
verify(() => storage.write(key: 'counter', value: '4')).called(1);
```

## Widget test (screen state)
```dart
Widget wrap(Widget child) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (context, _) => MaterialApp(theme: AppTheme.lightTheme, home: child),
);

testWidgets('ItemsBody shows error widget when loading failed', (tester) async {
  final bloc = ItemsBloc(FakeGetItemsUsecase(const Left(ServerFailure(message: 'x'))));
  addTearDown(bloc.close);
  bloc.add(const GetItemsEvent());

  await tester.pumpWidget(wrap(BlocProvider.value(value: bloc, child: const ItemsBody())));
  await tester.pumpAndSettle();

  expect(find.byType(MainErrorWidget), findsOneWidget);
});
```

Localized widgets need a localization wrapper. With easy_localization, either avoid `.tr()` in the widget under test, or initialize it with in-memory translations. Ask the user which approach to use the first time.
