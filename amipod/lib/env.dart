import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'privateIV')
  static String privateIV = _Env.privateIV;
  @EnviedField(varName: 'privateKey')
  static String privateKey = _Env.privateKey;
  @EnviedField(varName: 'googleMapsKey')
  static String googleMapsKey = _Env.googleMapsKey;
}
