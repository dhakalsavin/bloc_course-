import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => PersonsBloc(),
        child: const HomePage(),
      ),
    );
  }
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction extends LoadAction {
  final PersonUrl url;

  const LoadPersonsAction({required this.url}) : super();
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
}

enum PersonUrl { persons1, persons2 }

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        return "http://127.0.0.1:5500/testingbloc_course/api/persons1.json";
      case PersonUrl.persons2:
        return "http://127.0.0.1:5500/testingbloc_course/api/persons2.json";
    }
  }
}

//list to fetch the whole list and iterable for lazily load data
Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetreivedFromCache;

  const FetchResult(
      {required this.persons, required this.isRetreivedFromCache});

  @override
  String toString() =>
      'FetchResult (isRetreivedFromCache=$isRetreivedFromCache, persons=$persons)';
}

// load Action is the abstract as it cannot be constructed but we can access any class that extends the
// Load Action so we use teh loadAction as  the event
class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //for each person URl we are gonna cache the iterable of the person
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    //event is the input to the bolc and the emit is ouput to the bloc
    on<LoadPersonsAction>((event, emit) async {
      final url = event.url;
      if (_cache.containsKey(url)) {
        //we have value in cache
        final cachedPersons = _cache[url]!;
        final result =
            FetchResult(persons: cachedPersons, isRetreivedFromCache: true);
        emit(result);
      } else {
        // get the data from api
        final persons = await getPersons(url.urlString);
        //save the data to cache
        _cache[url] = persons;
        final result =
            FetchResult(persons: persons, isRetreivedFromCache: false);
        emit(result);
      }
    });
  }
}

//WE CANNOT USE list[2] for iterable but can for  list so customize

extension SubScript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    context
                        .read<PersonsBloc>()
                        .add(const LoadPersonsAction(url: PersonUrl.persons1));
                  },
                  child: const Text("Load json #1")),
              TextButton(
                  onPressed: () {
                    context
                        .read<PersonsBloc>()
                        .add(const LoadPersonsAction(url: PersonUrl.persons2));
                  },
                  child: const Text("Load json #2"))
            ],
          ),
          BlocBuilder<PersonsBloc, FetchResult?>(
              buildWhen: (previousResult, currentResult) {
            return previousResult?.persons != currentResult?.persons;
          }, builder: ((context, fetchResult) {
            fetchResult?.log();

            final persons = fetchResult?.persons;

            if (persons == null) {
              return const SizedBox();
            }
            return Expanded(
              child: ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index]!;

                  return ListTile(
                    title: Text(person.name),
                  );
                },
              ),
            );
          }))
        ],
      ),
    );
  }
}
