// import 'package:flutter/material.dart';
// import 'package:bloc/bloc.dart';
// import 'dart:math' as math show Random;
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const HomePage(),
//     );
//   }
// }

// const names = ['Foo', 'Bar', 'Baz'];

// extension RandomElement<T> on Iterable<T> {
//   T getRandomElement() => elementAt(math.Random().nextInt(length));
// }

// class NamesCubit extends Cubit<String?> {
//   NamesCubit() : super(null);

//   void pickRandomName() => emit(names.getRandomElement());
// }

// class HomePage extends StatefulWidget {
//   const HomePage({
//     super.key,
//   });

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final NamesCubit cubit;

//   @override
//   void initState() {
//     super.initState();
//     cubit = NamesCubit();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     cubit.close();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home Page"),
//       ),
//       body: StreamBuilder<String?>(
//           stream: cubit.stream,
//           builder: (context, snapshot) {
//             final button = TextButton(
//                 onPressed: () {
//                   cubit.pickRandomName();
//                 },
//                 child: const Text("pica random name "));

//             switch (snapshot.connectionState) {
//               case ConnectionState.none:
//                 return button;
//               case ConnectionState.waiting:
//                 return button;
//               case ConnectionState.active:
//                 return Column(
//                   children: [Text(snapshot.data ?? ""), button],
//                 );
//               case ConnectionState.done:
//                 return const SizedBox();
//             }
//           }),
//     );
//   }
// }
