import 'dart:async';
import 'package:flutter/material.dart';
import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';
import 'models/Object.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<QuerySnapshot<Object>> _subscription;
  final AmplifyDataStore _dataStorePlugin =
      AmplifyDataStore(modelProvider: ModelProvider.instance);
  final AmplifyAPI _apiPlugin = AmplifyAPI();
  final AmplifyAuthCognito _authPlugin = AmplifyAuthCognito();
  final _Id = "object";

  @override
  void initState() {
    // kick off app initialization
    _initializeApp();

    super.initState();
  }

  Future<void> _initializeApp() async {
    // configure Amplify
    await _configureAmplify();

    // after configuring Amplify, update loading ui state to loaded state
    _subscription = Amplify.DataStore.observeQuery(Object.classType)
        .listen((QuerySnapshot<Object> snapshot) {
      setState(() {
        // if (_isLoading) _isLoading = false;
        // _todos = snapshot.items;
      });
    });
  }

  Future<void> _configureAmplify() async {
    try {
      // add Amplify plugins
      await Amplify.addPlugins([_dataStorePlugin, _apiPlugin, _authPlugin]);

      // configure Amplify
      //
      // note that Amplify cannot be configured more than once!
      await Amplify.configure(amplifyconfig);
    } catch (e) {
      // error handling can be improved for sure!
      // but this will be sufficient for the purposes of this tutorial
      print('An error occurred while configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amplify CRUD',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CREATE
          FlatButton(
              onPressed: () => create(),
              child: Text('Create'),
              color: Colors.green,
              textColor: Colors.white),

          // READ ALL
          FlatButton(
              onPressed: () => readAll(),
              child: Text('Read ALL'),
              color: Colors.blue,
              textColor: Colors.white),

          // READ BY ID
          FlatButton(
              onPressed: () => readById(),
              child: Text('Read BY ID'),
              color: Colors.cyan,
              textColor: Colors.white),

          // UPDATE
          FlatButton(
              onPressed: () => update(),
              child: Text('Update'),
              color: Colors.orange,
              textColor: Colors.white),

          // DELETE
          FlatButton(
              onPressed: () => delete(),
              child: Text('Delete'),
              color: Colors.red,
              textColor: Colors.white),
        ],
      ),
    );
  }

  void create() async {
    final _Object = Object(id: _Id, value: "this is the object");

    try {
      await Amplify.DataStore.save(_Object);

      print('Saved ${_Object.toString()}');
    } catch (e) {
      print(e);
    }
  }

  void readAll() async {
    try {
      final _Objects = await Amplify.DataStore.query(Object.classType);

      print(_Objects.toString());
    } catch (e) {
      print(e);
    }
  }

  Future<Object> readById() async {
    try {
      final obj = await Amplify.DataStore.query(Object.classType,
          where: Object.ID.eq(_Id));

      if (obj.isEmpty) {
        print("No objects with ID: $_Id");
        // return null;
      }

      final _obj = obj.first;

      print(_obj.toString());

      return _obj;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void update() async {
    try {
      final _Objects = await readById();

      final updatedObject =
          _Objects.copyWith(value: _Objects.value + ' [UPDATED]');

      await Amplify.DataStore.save(updatedObject);

      print('Updated object to ${updatedObject.toString()}');
    } catch (e) {
      print(e);
    }
  }

  void delete() async {
    try {
      final myObject = await readById();

      await Amplify.DataStore.delete(myObject);

      print('Deleted object with ID: ${myObject.id}');
    } catch (e) {
      print(e);
    }
  }
}
