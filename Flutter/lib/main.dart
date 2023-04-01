import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}
enum ViewMode {
  grid, list
}
class MyAppState extends ChangeNotifier {
  //Atributos
  var current = WordPair.random();
  var history = <WordPair>[];
  GlobalKey? historyListKey;
  ViewMode _viewMode = ViewMode.list;
  var favorites = <WordPair>[];
  int _columns = 1;
  double _ratio = 10;
  var removeList = <WordPair>[];
  bool changeIsMade = false;

  //Getters
  IconData getIcon(WordPair fav){
    if (removeList.contains(fav)){
      return Icons.delete;
    }else {
      return Icons.favorite;
    }
  }
  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }


  //Metodos
  void toggleViewMode(){
    if (_viewMode == ViewMode.grid){
      _columns = 1;
      _ratio = 10;
      _viewMode = ViewMode.list;
    } else {
      _columns = 2;
      _ratio = 5;
      _viewMode = ViewMode.grid;
    }
  }
  void desFavorite(WordPair fav) {
    changeIsMade = true;
    if (removeList.contains(fav)) {
      removeList.remove(fav);
    } else {
      removeList.add(fav);
    }
    notifyListeners();
  }
  Widget applyButton(){
    if (changeIsMade){
      return ElevatedButton(onPressed: () {deleteFromList();}, child: Icon(Icons.check));
    }else {
      return SizedBox();
    }
  }
  void deleteFromList(){
    for (var item in removeList)
      if (favorites.contains(item)){
        favorites.remove(item);
      }
    changeIsMade = false;
    removeList.clear();
    notifyListeners();
  }
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),

              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          ApplyButton(),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Card(
                  shape: StadiumBorder(
                  ),
                  child:
                  SizedBox(
                    height: 35,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            iconSize: 20,
                            alignment: Alignment.topCenter,
                            icon: Icon(icon, color: Theme.of(context).colorScheme.primary,),
                            onPressed: () {
                              appState.toggleFavorite();
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                            child: Text('Like', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                          ),

                        ],
                      ),
                    ),
                  )
              ),

              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}



class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();

}

class _FavoritesPageState extends State<FavoritesPage> {
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Sem favoritos'),
      );
    }

    return Scaffold(
      appBar: AppBar( centerTitle: true,
        title: const Text("Favoritos"),actions: [IconButton(icon: Icon(appState._viewMode == ViewMode.list ? Icons.grid_on : Icons.view_list),
          onPressed: () {
            appState.toggleViewMode();
            appState.notifyListeners();
          },
        ),
      ],
    ),
    body: Container(
      child:
        GridView.count(
          crossAxisCount: appState._columns,
          childAspectRatio: appState._ratio,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        children: [
          for (var favorito in appState.favorites)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(onPressed: () {appState.desFavorite(favorito);},
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(appState.getIcon(favorito)),
                    ),
                    Text(favorito.asPascalCase),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    );
    }
  }

class ApplyButton extends StatelessWidget {
  const ApplyButton();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.changeIsMade){
      return ElevatedButton(onPressed: () {appState.deleteFromList();}, child: Icon(Icons.check));
    }else {
      return SizedBox();
    }
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: pair.asPascalCase,

        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items.
  final _key = GlobalKey();

  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

