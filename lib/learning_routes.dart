class LearningRoutes {
  const LearningRoutes._();

  static const home = '/';
  static const chapter03Lifecycle = '/chapter-03/lifecycle';
  static const chapter04Layout = '/chapter-04/layout';
  static const chapter05State = '/chapter-05/state';
  static const chapter06Transition = '/chapter-06/transitions';
  static const chapter07Lab = '/chapter-07/routes';
  static const chapter07TaskDetail = '/chapter-07/tasks/:taskId';
  static const chapter07Create = '/chapter-07/create';
  static const chapter07Search = '/chapter-07/search';
  static const chapter07Login = '/chapter-07/login';
  static const chapter08AsyncNetwork = '/chapter-08/async-network';
  static const chapter09LocalStorage = '/chapter-09/local-storage';
  static const chapter10Media = '/chapter-10/media';
  static const chapter11Engineering = '/chapter-11/engineering';

  static String taskDetailLocation(String taskId, {String? tab}) {
    return Uri(
      path: '/chapter-07/tasks/$taskId',
      queryParameters: tab == null ? null : {'tab': tab},
    ).toString();
  }

  static String searchLocation({required String keyword}) {
    return Uri(
      path: chapter07Search,
      queryParameters: {'keyword': keyword},
    ).toString();
  }

  static String loginLocation({required String from}) {
    return Uri(
      path: chapter07Login,
      queryParameters: {'from': from},
    ).toString();
  }
}
