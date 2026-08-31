import 'package:go_router/go_router.dart';

import 'chapter_03/lifecycle_demo_page.dart';
import 'chapter_04/layout_lab_page.dart';
import 'chapter_05/case_00_state_management_lab_page.dart';
import 'chapter_06/transition_lab_page.dart';
import 'chapter_07/route_create_task_page.dart';
import 'chapter_07/route_lab_models.dart';
import 'chapter_07/route_lab_page.dart';
import 'chapter_07/route_login_page.dart';
import 'chapter_07/route_search_page.dart';
import 'chapter_07/route_task_detail_page.dart';
import 'chapter_08/async_network_lab_page.dart';
import 'chapter_09/local_storage_lab_page.dart';
import 'chapter_10/media_lab_page.dart';
import 'chapter_11/engineering_checklist_page.dart';
import 'chapter_13/localization_lab_page.dart';
import 'chapter_14/firebase_auth_lab_page.dart';
import 'chapter_15/chat_keyboard_jank_page.dart';
import 'learning_home_page.dart';
import 'learning_routes.dart';

GoRouter createLearningRouter(RouteLabSession session) {
  return GoRouter(
    initialLocation: LearningRoutes.home,
    refreshListenable: session,
    redirect: (context, state) {
      final path = state.uri.path;
      final isProtectedTaskDetail = path.startsWith('/chapter-07/tasks/');

      if (isProtectedTaskDetail && !session.isLoggedIn) {
        return LearningRoutes.loginLocation(from: state.uri.toString());
      }

      return null;
    },
    routes: [
      GoRoute(
        path: LearningRoutes.home,
        builder: (context, state) => const LearningHomePage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter03Lifecycle,
        builder: (context, state) => const LifecycleDemoPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter04Layout,
        builder: (context, state) => const LayoutLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter05State,
        builder: (context, state) => const StateManagementLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter06Transition,
        builder: (context, state) => const TransitionLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter07Lab,
        builder: (context, state) => RouteLabPage(session: session),
      ),
      GoRoute(
        path: LearningRoutes.chapter07TaskDetail,
        builder: (context, state) {
          return RouteTaskDetailPage(
            taskId: state.pathParameters['taskId'] ?? '',
            tab: state.uri.queryParameters['tab'] ?? 'overview',
            extraTask: state.extra is RouteLabTask
                ? state.extra as RouteLabTask
                : null,
          );
        },
      ),
      GoRoute(
        path: LearningRoutes.chapter07Create,
        builder: (context, state) => const RouteCreateTaskPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter07Search,
        builder: (context, state) {
          return RouteSearchPage(
            keyword: state.uri.queryParameters['keyword'] ?? '',
          );
        },
      ),
      GoRoute(
        path: LearningRoutes.chapter07Login,
        builder: (context, state) {
          return RouteLoginPage(
            session: session,
            from: state.uri.queryParameters['from'] ?? '',
          );
        },
      ),
      GoRoute(
        path: LearningRoutes.chapter08AsyncNetwork,
        builder: (context, state) => const AsyncNetworkLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter09LocalStorage,
        builder: (context, state) => const LocalStorageLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter10Media,
        builder: (context, state) => const MediaLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter11Engineering,
        builder: (context, state) => const EngineeringChecklistPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter13Localization,
        builder: (context, state) => const LocalizationLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter14FirebaseAuth,
        builder: (context, state) => const FirebaseAuthLabPage(),
      ),
      GoRoute(
        path: LearningRoutes.chapter15ChatKeyboardJank,
        builder: (context, state) => const ChatKeyboardJankPage(),
      ),
    ],
  );
}
