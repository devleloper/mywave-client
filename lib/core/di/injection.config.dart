// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i9;

import '../../data/datasources/local/audio_player_service.dart' as _i5;
import '../../data/datasources/local/auth_storage.dart' as _i7;
import '../../data/datasources/local/download_service.dart' as _i16;
import '../../data/datasources/local/track_storage.dart' as _i10;
import '../../data/datasources/remote/catalog_repository_impl.dart' as _i13;
import '../../domain/repositories/audio_player_repository.dart' as _i4;
import '../../domain/repositories/catalog_repository.dart' as _i12;
import '../../domain/repositories/download_repository.dart' as _i15;
import '../../presentation/features/album/bloc/album_bloc.dart' as _i19;
import '../../presentation/features/artist/bloc/artist_bloc.dart' as _i20;
import '../../presentation/features/collection/bloc/collection_bloc.dart'
    as _i14;
import '../../presentation/features/home/bloc/home_bloc.dart' as _i17;
import '../../presentation/features/player/bloc/audio_player_bloc.dart' as _i11;
import '../../presentation/features/search/bloc/search_bloc.dart' as _i18;
import '../network/auth_interceptor.dart' as _i6;
import '../network/network_module.dart' as _i21;
import '../router/app_router.dart' as _i3;
import '../services/local_proxy_server.dart' as _i23;
import 'storage_module.dart' as _i22;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    final storageModule = _$StorageModule();
    gh.singleton<_i3.AppRouter>(() => _i3.AppRouter());
    gh.lazySingleton<_i4.AudioPlayerRepository>(
        () => _i5.AudioPlayerServiceImpl(
              gh<_i7.AuthStorage>(),
              gh<_i23.LocalProxyServer>(),
            ));
    gh.lazySingleton<_i6.AuthInterceptor>(() => _i6.AuthInterceptor());
    gh.lazySingleton<_i7.AuthStorage>(() => _i7.AuthStorageImpl());
    gh.lazySingleton<_i8.Dio>(() => networkModule.dio);
    await gh.singletonAsync<_i9.Isar>(
      () => storageModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i10.TrackStorage>(
        () => _i10.TrackStorageImpl(gh<_i9.Isar>()));
    gh.factory<_i11.AudioPlayerBloc>(
        () => _i11.AudioPlayerBloc(gh<_i4.AudioPlayerRepository>(), gh<_i12.CatalogRepository>()));
    gh.lazySingleton<_i12.CatalogRepository>(
        () => _i13.CatalogRepositoryImpl(gh<_i8.Dio>()));
    gh.factory<_i14.CollectionBloc>(
        () => _i14.CollectionBloc(gh<_i10.TrackStorage>()));
    gh.lazySingleton<_i15.DownloadRepository>(() => _i16.DownloadServiceImpl(
          gh<_i8.Dio>(),
          gh<_i10.TrackStorage>(),
        ));
    gh.factory<_i17.HomeBloc>(
        () => _i17.HomeBloc(gh<_i12.CatalogRepository>()));
    gh.factory<_i18.SearchBloc>(
        () => _i18.SearchBloc(gh<_i12.CatalogRepository>()));
    gh.factory<_i19.AlbumBloc>(
        () => _i19.AlbumBloc(gh<_i12.CatalogRepository>()));
    gh.factory<_i20.ArtistBloc>(
        () => _i20.ArtistBloc(gh<_i12.CatalogRepository>()));
    return this;
  }
}

class _$NetworkModule extends _i21.NetworkModule {}

class _$StorageModule extends _i22.StorageModule {}
